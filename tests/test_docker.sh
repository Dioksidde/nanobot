#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1

IMAGE_NAME="nanobot-test"

echo "=== Building Docker image ==="
docker build -t "$IMAGE_NAME" .

echo ""
echo "=== Running 'nanobot status' (entrypoint auto-onboards) ==="
STATUS_OUTPUT=$(docker run --rm \
    -e NANOBOT_OPENROUTER_API_KEY=test-key \
    "$IMAGE_NAME" status 2>&1) || true

echo "$STATUS_OUTPUT"

echo ""
echo "=== Validating output ==="
PASS=true

check() {
    if echo "$STATUS_OUTPUT" | grep -q "$1"; then
        echo "  PASS: found '$1'"
    else
        echo "  FAIL: missing '$1'"
        PASS=false
    fi
}

check "nanobot Status"
check "Config:"
check "Workspace:"
check "Model:"
check "OpenRouter API:"
check "Anthropic API:"
check "OpenAI API:"

echo ""
echo "=== Validating non-root user ==="
USER_OUTPUT=$(docker run --rm "$IMAGE_NAME" sh -c 'whoami' 2>&1) || true
if [ "$USER_OUTPUT" = "nanobot" ]; then
    echo "  PASS: running as 'nanobot' user"
else
    echo "  FAIL: expected 'nanobot' user, got '$USER_OUTPUT'"
    PASS=false
fi

echo ""
echo "=== Validating healthcheck script exists ==="
HC_OUTPUT=$(docker run --rm "$IMAGE_NAME" sh -c 'test -x /app/healthcheck.sh && echo ok' 2>&1) || true
if [ "$HC_OUTPUT" = "ok" ]; then
    echo "  PASS: healthcheck.sh is executable"
else
    echo "  FAIL: healthcheck.sh missing or not executable"
    PASS=false
fi

echo ""
if $PASS; then
    echo "=== All checks passed ==="
else
    echo "=== Some checks FAILED ==="
    exit 1
fi

# Cleanup
echo ""
echo "=== Cleanup ==="
docker rmi -f "$IMAGE_NAME" 2>/dev/null || true
echo "Done."
