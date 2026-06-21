#!/usr/bin/env bash
# "Is any /dev/video* device currently held open?" — asked of the kernel directly.

active=0
busy_nodes=()

shopt -s nullglob
for node in /dev/video*; do
    # Try to open the device for read. If something else holds it exclusively,
    # OR if there's any reader, lsof will report it.
    if lsof "$node" >/dev/null 2>&1; then
        active=1
        busy_nodes+=("$node")
    fi
done

if [[ "$1" == "--who" ]]; then
    if (( active )); then
        info=$(lsof "${busy_nodes[@]}" 2>/dev/null | awk 'NR>1 {print $1" (PID "$2")"}' | sort -u)
        notify-send "Webcam active" "$info"
    else
        notify-send "Webcam idle" "No process is using /dev/video*"
    fi
    exit 0
fi

if (( active )); then
    printf '{"text":"󰄀","alt":"active","tooltip":"Webcam in use","class":"active"}\n'
fi

