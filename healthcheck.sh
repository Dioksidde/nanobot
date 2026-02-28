#!/bin/sh
# Liveness probe: checks that the gateway is writing its health file recently.

HEALTH_FILE="$HOME/.nanobot/.health"
MAX_AGE=30  # seconds

if [ ! -f "$HEALTH_FILE" ]; then
    exit 1
fi

LAST_WRITE=$(cat "$HEALTH_FILE")
NOW=$(date +%s)
AGE=$((NOW - LAST_WRITE))

if [ "$AGE" -gt "$MAX_AGE" ]; then
    exit 1
fi

exit 0
