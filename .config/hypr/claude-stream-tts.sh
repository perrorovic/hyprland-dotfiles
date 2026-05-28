#!/usr/bin/env bash
# claude-stream-tts
# foreground watcher: speaks new assistant replies via piper, by detecting
# when a new assistant message is added to the session JSONL (no debounce).

# ---- config ----
PIDFILE="/tmp/claude-stream-tts.pid"
PLAYBACK_PIDFILE="/tmp/claude-stream-tts.playback.pid"
ACTIVE_FILE_RECORD="/tmp/claude-stream-tts.activefile"
CURRENT_FILE="/tmp/claude-stream-tts.current"
COUNT_FILE="/tmp/claude-stream-tts.count"
PIPER_SCRIPT="$HOME/.config/hypr/piper-tts.sh"

# ---- helpers ----
fetch_active_file() {
  ssh phitc 'ls -t ~/.claude/projects/-home-perrorovic/*.jsonl | head -n 1' 2>/dev/null
}

fetch_count() {
  ssh phitc 'jq -s "[.[] | select(.type==\"assistant\")] | length" \
    "$(ls -t ~/.claude/projects/-home-perrorovic/*.jsonl | head -n 1)" 2>/dev/null'
}

fetch_latest_text() {
  ssh phitc 'jq -rs "[.[] | select(.type==\"assistant\")] | last | .message.content[]? | select(.type==\"text\") | .text" \
    "$(ls -t ~/.claude/projects/-home-perrorovic/*.jsonl | head -n 1)" 2>/dev/null'
}

clean_text() {
  awk 'BEGIN{inblock=0} /^[[:space:]]*```/ {inblock=!inblock; next} !inblock {print}' | \
  sed -E '
    s/\*\*([^*]+)\*\*/\1/g
    s/\*([^*]+)\*/\1/g
    s/`([^`]+)`/\1/g
    s/\[([^]]+)\]\([^)]+\)/\1/g
    s/^#+[[:space:]]*//
    s/→/ to /g
    s/&/ and /g
  '
}

kill_playback() {
  if [ -f "$PLAYBACK_PIDFILE" ]; then
    PID=$(cat "$PLAYBACK_PIDFILE")
    kill -TERM -- -"$PID" 2>/dev/null
    sleep 0.2
    kill -KILL -- -"$PID" 2>/dev/null
    rm -f "$PLAYBACK_PIDFILE"
  fi
  pkill -KILL -f 'piper-tts.*--model' 2>/dev/null
  pkill -KILL -f 'paplay.*--raw.*22050' 2>/dev/null
}

stop_watcher() {
  kill_playback
  if [ -f "$PIDFILE" ]; then
    kill -TERM -- -"$(cat "$PIDFILE")" 2>/dev/null
    sleep 0.2
    kill -KILL -- -"$(cat "$PIDFILE")" 2>/dev/null
  fi
  pkill -f 'ssh phitc.*inotifywait' 2>/dev/null
  ssh phitc 'pkill -f inotifywait' 2>/dev/null
  rm -f "$PIDFILE" "$PLAYBACK_PIDFILE"
}

# ---- subcommands ----
case "$1" in
  --stop)
    stop_watcher
    notify-send -u low -t 2000 "Claude Stream TTS" "Stopped"
    exit 0
    ;;
  --cleanup)
    stop_watcher
    rm -f "$CURRENT_FILE" "$COUNT_FILE" "$ACTIVE_FILE_RECORD"
    notify-send -u low -t 2000 "Claude Stream TTS" "Cleaned"
    echo "[cleanup] done"
    exit 0
    ;;
  --skip)
    kill_playback
    notify-send -u low -t 1000 "Claude Stream TTS" "Skipped"
    exit 0
    ;;
esac

# ---- main ----
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "[watcher] already running (pid $(cat $PIDFILE)). Use --stop or --cleanup."
  exit 0
fi

if [ ! -x "$PIPER_SCRIPT" ]; then
  echo "[watcher] ERROR: piper script not executable: $PIPER_SCRIPT"
  exit 1
fi

echo $$ > "$PIDFILE"

# initialise baseline count and active file so we don't speak existing history on startup
INITIAL_COUNT=$(fetch_count)
INITIAL_COUNT=${INITIAL_COUNT:-0}
echo "$INITIAL_COUNT" > "$COUNT_FILE"

INITIAL_FILE=$(fetch_active_file)
echo "$INITIAL_FILE" > "$ACTIVE_FILE_RECORD"

echo "[watcher] starting"
echo "[watcher] watching: $(basename "$INITIAL_FILE")"
echo "[watcher] initial assistant count: $INITIAL_COUNT"
echo "[watcher] ctrl-c to stop"
notify-send -u low -t 2000 "Claude Stream TTS" "Started"

# named pipe so we can read events without putting the loop inside a pipeline,
# which lets Ctrl-C reach the main script instead of being trapped by SSH
FIFO=$(mktemp -u)
mkfifo "$FIFO"

ssh phitc 'inotifywait -m -q -e modify ~/.claude/projects/-home-perrorovic/ |
  grep --line-buffered "\.jsonl$" | while read -r _; do echo CHANGED; done' > "$FIFO" 2>/dev/null &
SSH_PID=$!

cleanup_and_exit() {
  trap '' INT TERM
  echo ""
  echo "[watcher] stopping..."
  kill -KILL "$SSH_PID" 2>/dev/null
  wait "$SSH_PID" 2>/dev/null
  rm -f "$FIFO"
  stop_watcher
  echo "[watcher] stopped"
  exit 0
}

trap cleanup_and_exit INT TERM

while read -r _; do
  # detect session/file change first; reset baseline if the active jsonl has switched
  CURRENT_FILE_PATH=$(fetch_active_file)
  PREV_FILE_PATH=$(cat "$ACTIVE_FILE_RECORD" 2>/dev/null || echo "")

  if [ "$CURRENT_FILE_PATH" != "$PREV_FILE_PATH" ]; then
    echo "[watcher] new session detected: $(basename "$CURRENT_FILE_PATH")"
    echo "$CURRENT_FILE_PATH" > "$ACTIVE_FILE_RECORD"
    NEW_BASELINE=$(fetch_count)
    NEW_BASELINE=${NEW_BASELINE:-0}
    echo "$NEW_BASELINE" > "$COUNT_FILE"
    continue
  fi

  CURRENT_COUNT=$(fetch_count)
  CURRENT_COUNT=${CURRENT_COUNT:-0}
  PREV_COUNT=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)

  if [ "$CURRENT_COUNT" -le "$PREV_COUNT" ]; then
    continue
  fi

  echo "[watcher] new assistant message detected (count: $PREV_COUNT -> $CURRENT_COUNT)"
  echo "$CURRENT_COUNT" > "$COUNT_FILE"

  TEXT=$(fetch_latest_text | clean_text)
  if [ -z "$TEXT" ]; then
    echo "[watcher] empty text, skipping"
    continue
  fi

  if [ -f "$PLAYBACK_PIDFILE" ]; then
    OLD=$(cat "$PLAYBACK_PIDFILE")
    if kill -0 "$OLD" 2>/dev/null; then
      echo "[watcher] waiting for current playback to finish..."
      wait "$OLD" 2>/dev/null
    fi
    rm -f "$PLAYBACK_PIDFILE"
  fi

  printf '%s' "$TEXT" > "$CURRENT_FILE"
  echo "[watcher] speaking (${#TEXT} chars)"
  setsid bash -c "printf '%s' \"\$1\" | \"$PIPER_SCRIPT\"" _ "$TEXT" &
  echo $! > "$PLAYBACK_PIDFILE"
done < "$FIFO"

rm -f "$FIFO"
stop_watcher

