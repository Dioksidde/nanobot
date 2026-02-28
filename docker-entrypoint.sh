#!/bin/sh
set -e

CONFIG_DIR="$HOME/.nanobot"
CONFIG_FILE="$CONFIG_DIR/config.json"
TEMPLATE_FILE="/app/config.template.json"

# --- Step 1: Generate config from template if none exists ---
if [ ! -f "$CONFIG_FILE" ] && [ -f "$TEMPLATE_FILE" ]; then
    mkdir -p "$CONFIG_DIR"

    # Set defaults for unset variables
    : "${NANOBOT_OPENROUTER_API_KEY:=}"
    : "${NANOBOT_ANTHROPIC_API_KEY:=}"
    : "${NANOBOT_OPENAI_API_KEY:=}"
    : "${NANOBOT_DEEPSEEK_API_KEY:=}"
    : "${NANOBOT_GROQ_API_KEY:=}"
    : "${NANOBOT_GEMINI_API_KEY:=}"
    : "${NANOBOT_CUSTOM_API_KEY:=}"
    : "${NANOBOT_CUSTOM_API_BASE:=}"
    : "${NANOBOT_MODEL:=anthropic/claude-opus-4-5}"
    : "${NANOBOT_MAX_TOKENS:=8192}"
    : "${NANOBOT_TEMPERATURE:=0.7}"
    : "${NANOBOT_TELEGRAM_ENABLED:=false}"
    : "${NANOBOT_TELEGRAM_TOKEN:=}"
    : "${NANOBOT_DISCORD_ENABLED:=false}"
    : "${NANOBOT_DISCORD_TOKEN:=}"
    : "${NANOBOT_SLACK_ENABLED:=false}"
    : "${NANOBOT_SLACK_BOT_TOKEN:=}"
    : "${NANOBOT_SLACK_APP_TOKEN:=}"
    : "${NANOBOT_FEISHU_ENABLED:=false}"
    : "${NANOBOT_FEISHU_APP_ID:=}"
    : "${NANOBOT_FEISHU_APP_SECRET:=}"
    : "${NANOBOT_WHATSAPP_ENABLED:=false}"
    : "${NANOBOT_WHATSAPP_BRIDGE_URL:=ws://localhost:3001}"
    : "${NANOBOT_BRAVE_API_KEY:=}"
    : "${NANOBOT_RESTRICT_TO_WORKSPACE:=false}"
    : "${NANOBOT_GATEWAY_PORT:=18790}"

    export NANOBOT_OPENROUTER_API_KEY NANOBOT_ANTHROPIC_API_KEY NANOBOT_OPENAI_API_KEY
    export NANOBOT_DEEPSEEK_API_KEY NANOBOT_GROQ_API_KEY NANOBOT_GEMINI_API_KEY
    export NANOBOT_CUSTOM_API_KEY NANOBOT_CUSTOM_API_BASE
    export NANOBOT_MODEL NANOBOT_MAX_TOKENS NANOBOT_TEMPERATURE
    export NANOBOT_TELEGRAM_ENABLED NANOBOT_TELEGRAM_TOKEN
    export NANOBOT_DISCORD_ENABLED NANOBOT_DISCORD_TOKEN
    export NANOBOT_SLACK_ENABLED NANOBOT_SLACK_BOT_TOKEN NANOBOT_SLACK_APP_TOKEN
    export NANOBOT_FEISHU_ENABLED NANOBOT_FEISHU_APP_ID NANOBOT_FEISHU_APP_SECRET
    export NANOBOT_WHATSAPP_ENABLED NANOBOT_WHATSAPP_BRIDGE_URL
    export NANOBOT_BRAVE_API_KEY NANOBOT_RESTRICT_TO_WORKSPACE NANOBOT_GATEWAY_PORT

    envsubst < "$TEMPLATE_FILE" > "$CONFIG_FILE"
    echo "Generated config from template at $CONFIG_FILE"
fi

# --- Step 2: Auto-onboard if workspace doesn't exist ---
WORKSPACE_DIR="$CONFIG_DIR/workspace"
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "Running initial onboard..."
    echo "N" | nanobot onboard || true
fi

# --- Step 3: Hand off to nanobot ---
exec nanobot "$@"
