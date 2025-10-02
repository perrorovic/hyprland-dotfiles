#!/bin/bash

case "$1" in
  -pp|--playpause)
    dbus-send \
      --print-reply \
      --dest=org.mpris.MediaPlayer2.spotify \
      /org/mpris/MediaPlayer2 \
      org.mpris.MediaPlayer2.Player.PlayPause
    ;;
  -n|--next)
    dbus-send \
      --print-reply \
      --dest=org.mpris.MediaPlayer2.spotify \
      /org/mpris/MediaPlayer2 \
      org.mpris.MediaPlayer2.Player.Next
    ;;
  -p|--prev|--previous)
    dbus-send \
      --print-reply \
      --dest=org.mpris.MediaPlayer2.spotify \
      /org/mpris/MediaPlayer2 \
      org.mpris.MediaPlayer2.Player.Previous
    ;;
  -i|--info)
    qdbus6 \
      --literal org.mpris.MediaPlayer2.spotify \
      /org/mpris/MediaPlayer2 \
      org.freedesktop.DBus.Properties.Get \
      org.mpris.MediaPlayer2.Player \
      Metadata
    ;;
  *)
    echo "Usage: $0 [--playpause|-pp] [--next|-n] [--prev|--previous|-p] [--info|-i]"
    exit 1
    ;;
esac
