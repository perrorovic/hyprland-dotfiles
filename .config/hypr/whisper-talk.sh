#!/usr/bin/env bash
set -e

APP_NAME="Whisper Talk & Transcribe"
WHISPER_DIR="$HOME/.whisper.cpp"
MODEL="$WHISPER_DIR/models/ggml-small.en.bin"
WHISPER_BIN="$WHISPER_DIR/build/bin/whisper-cli"
PIDFILE="/tmp/whisper-talk.pid"
WAVFILE="/tmp/whisper-talk.wav"
DEFAULT_OUTPUT="copy" #"copy" or "type"
TAIL_BUFFER=1.0 #seconds of audio kept after pressing transcribe

NOTIFICATION="notify-send -u low -t 2000 -r 9898"

usage() {
  cat <<EOF
Usage: $APP_NAME [--listen|--transcribe|--toggle|--status] [--copy|--type]

  --listen      Start recording (replaces any existing recording)
  --transcribe  Stop recording, transcribe, output result
  --toggle      Listen if idle, transcribe if recording (default)
  --status      Print "recording" or "idle"

Output (decided at transcribe time, default: $DEFAULT_OUTPUT):
  --copy        Copy result to clipboard (wl-copy)
  --type        Type result into focused window (wtype)
EOF
  exit 1
}

OUTPUT="$DEFAULT_OUTPUT"
ACTION="--toggle"
for arg in "$@"; do
  case "$arg" in
    --copy) OUTPUT="copy" ;;
    --type) OUTPUT="type" ;;
    --listen|--transcribe|--toggle|--status) ACTION="$arg" ;;
    -h|--help) usage ;;
    *) usage ;;
  esac
done

start_listen() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    kill -INT "$PID" 2>/dev/null || true
    wait "$PID" 2>/dev/null || true
    rm -f "$PIDFILE" "$WAVFILE"
  fi
  sox -d -r 16000 -c 1 -b 16 "$WAVFILE" 2>/dev/null &
  echo $! > "$PIDFILE"
  $NOTIFICATION "$APP_NAME" "Listening..."
}

stop_transcribe() {
  if [ ! -f "$PIDFILE" ]; then
    $NOTIFICATION "$APP_NAME" "not recording"
    exit 1
  fi
  PID=$(cat "$PIDFILE")
  rm -f "$PIDFILE"

  sleep "$TAIL_BUFFER"

  kill -INT "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true

  $NOTIFICATION "$APP_NAME" "Transcribing..."

  START=$EPOCHREALTIME

  TEXT=$("$WHISPER_BIN" -m "$MODEL" -f "$WAVFILE" -nt 2>/dev/null \
    | tr -d '\n' | sed 's/^ *//;s/ *$//')

  rm -f "$WAVFILE"

  if [ -z "$TEXT" ]; then
    $NOTIFICATION "$APP_NAME" "No speech detected"
    return
  fi

  END=$EPOCHREALTIME
  ELAPSED=$(awk -v s="$START" -v e="$END" 'BEGIN { printf "%.2f", e - s }')

  case "$OUTPUT" in
    type)
      wtype -- "$TEXT"
      $NOTIFICATION "$APP_NAME" "Typed out (${ELAPSED}s)"
      ;;
    copy|*)
      printf '%s' "$TEXT" | wl-copy
      $NOTIFICATION "$APP_NAME" "Copied to clipboard (${ELAPSED}s)"
      ;;
  esac
}

case "$ACTION" in
  --listen)     start_listen ;;
  --transcribe) stop_transcribe ;;
  --toggle)
    if [ -f "$PIDFILE" ]; then stop_transcribe; else start_listen; fi
    ;;
  --status)
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo recording
    else
      echo idle
    fi
    ;;
esac

