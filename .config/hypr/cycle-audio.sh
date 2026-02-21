#!/bin/bash

set -euo pipefail

# Get all available sink names
mapfile -t SINKS < <(pactl list short sinks | awk '{print $2}')

if [[ ${#SINKS[@]} -eq 0 ]]; then
  echo "No audio sinks found." >&2
  exit 1
fi

# Get the currently active default sink
CURRENT=$(pactl get-default-sink)

# Find the index of the current sink
CURRENT_IDX=-1
for i in "${!SINKS[@]}"; do
  if [[ "${SINKS[$i]}" == "$CURRENT" ]]; then
    CURRENT_IDX=$i
    break
  fi
done

# Calculate next sink index (wraps around)
NEXT_IDX=$(( (CURRENT_IDX + 1) % ${#SINKS[@]} ))
NEXT_SINK="${SINKS[$NEXT_IDX]}"

# Set the new default sink
pactl set-default-sink "$NEXT_SINK"

# Move all currently playing streams to the new sink
while IFS= read -r stream_idx; do
  pactl move-sink-input "$stream_idx" "$NEXT_SINK"
done < <(pactl list short sink-inputs | awk '{print $1}')

# Get better display name for notification
TOTAL=${#SINKS[@]}
IDX=$(( NEXT_IDX + 1 ))

display_name() {
  local name="$1"
  if [[ "$name" == *"usb"* ]]; then
    # Extract device label from USB sink name
    echo "$name" | grep -oP '(?<=usb-).*?(?=\.\w+-stereo|\.\w+-surround)' \
      | sed 's/_/ /g; s/  */ /g; s/00000000//g; s/^ //; s/ $//'
  else
    echo "$name" | sed 's/alsa_output\.//; s/pci-[0-9a-fx:._]*\.//; s/\./ /g; s/  */ /g'
  fi
}

LABEL=$(display_name "$NEXT_SINK")
[[ -z "$LABEL" ]] && LABEL="$NEXT_SINK"

# Send notification
if command -v notify-send &>/dev/null; then
  notify-send -t 2000 "Audio Output Switched" "$LABEL ($IDX/$TOTAL)"
fi
