#!/usr/bin/env bash

on=0
for f in /sys/class/leds/*capslock*/brightness; do
    [ -r "$f" ] || continue
    [ "$(cat "$f" 2>/dev/null)" != "0" ] && on=1
done
if [ "$on" = "1" ]; then
    echo '{"text":"󰪛","class":"active","tooltip":"Caps Lock ON"}'
else
    echo '{"text":"󰪛","class":"inactive","tooltip":"Caps Lock OFF"}'
fi
