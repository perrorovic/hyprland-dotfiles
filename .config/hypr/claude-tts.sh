#!/usr/bin/env bash
set -e

TEXT=$(ssh phitc bash <<'REMOTE'
set -e
PROJECT_DIR="$HOME/.claude/projects/-home-perrorovic"
LATEST=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | head -n 1)
if [ -z "$LATEST" ]; then
  exit 1
fi
jq -rs '
  [.[] | select(.type == "assistant")] | last |
  .message.content[]? | select(.type == "text") | .text
' "$LATEST"
REMOTE
)

if [ -z "$TEXT" ]; then
  notify-send -u low -t 2000 "speak-last-reply" "no reply found"
  exit 1
fi

CLEAN=$(printf '%s' "$TEXT" | \
  awk 'BEGIN{inblock=0} /^[[:space:]]*```/ {inblock=!inblock; next} !inblock {print}' | \
  sed -E '
    s/\*\*([^*]+)\*\*/\1/g
    s/\*([^*]+)\*/\1/g
    s/`([^`]+)`/\1/g
    s/\[([^]]+)\]\([^)]+\)/\1/g
    s/^#+[[:space:]]*//
    s/→/ to /g
    s/&/ and /g
  ')

printf '%s' "$CLEAN" | "$HOME/.config/hypr/piper-tts.sh"

