#!/usr/bin/env bash
set -e

MODEL="$HOME/.piper-tts/models/en_US-libritts_r-medium.onnx"
SPEAKER=120
LENGTH_SCALE=1.0
NOISE_SCALE=0.62
NOISE_W_SCALE=0.32
SENTENCE_SILENCE=0.2

# device profiles: per-sink volume overrides (regex matched against sink name)
# format: "regex|percent"
DEVICE_PROFILES=(
  "HyperX|37.5%"          # headset
  "analog-stereo|50%"   # default speakers
)
DEFAULT_VOLUME="50%"

# convert "33%", "33", "33.5%" → integer in paplay's 0-65536 range
pct_to_raw() {
  local input="${1%\%}"
  awk -v p="$input" 'BEGIN { printf "%d", (p * 65536 / 100) + 0.5 }'
}

ARGS=()
FORCE_VOLUME=""
FORCE_SINK=""
while [ $# -gt 0 ]; do
  case "$1" in
    --voice) SPEAKER="$2"; shift 2 ;;
    --voice=*) SPEAKER="${1#--voice=}"; shift ;;
    --length) LENGTH_SCALE="$2"; shift 2 ;;
    --length=*) LENGTH_SCALE="${1#--length=}"; shift ;;
    --device) FORCE_SINK="$2"; shift 2 ;;
    --device=*) FORCE_SINK="${1#--device=}"; shift ;;
    --volume) FORCE_VOLUME="$2"; shift 2 ;;
    --volume=*) FORCE_VOLUME="${1#--volume=}"; shift ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

# auto-detect the active sink: prefer RUNNING, fall back to default
if [ -z "$FORCE_SINK" ]; then
  SINK=$(pactl list sinks short | awk '$NF == "RUNNING" { print $2; exit }')
  if [ -z "$SINK" ]; then
    SINK=$(pactl get-default-sink 2>/dev/null)
  fi
else
  SINK="$FORCE_SINK"
fi

# pick volume based on which profile the sink matches
if [ -n "$FORCE_VOLUME" ]; then
  VOLUME_PCT="$FORCE_VOLUME"
else
  VOLUME_PCT="$DEFAULT_VOLUME"
  for profile in "${DEVICE_PROFILES[@]}"; do
    REGEX="${profile%%|*}"
    VOL="${profile##*|}"
    if [[ "$SINK" =~ $REGEX ]]; then
      VOLUME_PCT="$VOL"
      break
    fi
  done
fi

VOLUME=$(pct_to_raw "$VOLUME_PCT")

PAPLAY_ARGS=(--raw --rate=22050 --format=s16le --channels=1 --volume="$VOLUME")
[ -n "$SINK" ] && PAPLAY_ARGS+=(--device="$SINK")

if [ ${#ARGS[@]} -gt 0 ]; then
  TEXT="${ARGS[*]}"
else
  TEXT=$(cat)
fi

echo "[piper-speak] sink=$SINK volume=$VOLUME_PCT (raw=$VOLUME)" >&2

printf '%s' "$TEXT" | piper-tts \
  --model "$MODEL" \
  --speaker "$SPEAKER" \
  --length-scale "$LENGTH_SCALE" \
  --noise-scale "$NOISE_SCALE" \
  --noise-w-scale "$NOISE_W_SCALE" \
  --sentence-silence "$SENTENCE_SILENCE" \
  --output-raw | \
  paplay "${PAPLAY_ARGS[@]}"

