# ============================================================
# Stage 1: Builder — install Python deps + build WhatsApp bridge
# ============================================================
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

# Install Node.js 20 + build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg git && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create venv and install Python dependencies (cached layer)
RUN uv venv /opt/venv
COPY pyproject.toml README.md LICENSE ./
RUN mkdir -p nanobot bridge && touch nanobot/__init__.py && \
    uv pip install --python /opt/venv/bin/python --no-cache . && \
    rm -rf nanobot bridge

# Copy full source and install into venv
COPY nanobot/ nanobot/
COPY bridge/ bridge/
RUN uv pip install --python /opt/venv/bin/python --no-cache .

# Build WhatsApp bridge and prune devDependencies
WORKDIR /app/bridge
RUN npm install && npm run build && npm prune --production
WORKDIR /app

# ============================================================
# Stage 2: Runtime — minimal image with non-root user
# ============================================================
FROM python:3.12-slim-bookworm

# Install Node.js 20 runtime + envsubst (gettext-base)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates gnupg gettext-base && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get purge -y gnupg curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1001 nanobot && useradd -u 1001 -g nanobot -m -s /bin/sh nanobot

WORKDIR /app

# Copy Python venv from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application source and workspace templates
COPY nanobot/ nanobot/
COPY workspace/ workspace/
COPY pyproject.toml README.md LICENSE ./

# Copy bridge dist + pruned node_modules
COPY --from=builder /app/bridge/dist/ bridge/dist/
COPY --from=builder /app/bridge/node_modules/ bridge/node_modules/
COPY --from=builder /app/bridge/package.json bridge/package.json

# Copy Docker support files
COPY config.template.json /app/config.template.json
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
COPY healthcheck.sh /app/healthcheck.sh
RUN chmod +x /app/docker-entrypoint.sh /app/healthcheck.sh

# Create data directory owned by nanobot user
RUN mkdir -p /home/nanobot/.nanobot && chown -R nanobot:nanobot /home/nanobot/.nanobot

USER nanobot

# Gateway default port
EXPOSE 18790

HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
    CMD ["/app/healthcheck.sh"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["gateway"]
