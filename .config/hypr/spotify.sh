#!/bin/bash

usage() {
cat <<EOF
Usage:
  $0 [OPTIONS] - Phiery's custom spotify controller

Options:
  -n, --next            Next song
  -p, --previous        Previous song
  -c, --current         Check current song
  -pp, --playpause      Toggle play/pause
  -vu, --volume-up      App volume +5%
  -vd, --volume-down    App volume -5%
EOF
}

NOTIFICATION="notify-send -u low -t 2000 -r 9898"

case "$1" in
	# Using playerctl
	--play-pause|-pp)
		if [ "$(playerctl status --player=spotify)" = "Paused" ]; then
			$NOTIFICATION "Spotify Resume" "$(playerctl metadata --format '{{artist}} - {{title}}' --player=spotify)"
		else
			$NOTIFICATION "Spotify Paused" "$(playerctl metadata --format '{{artist}} - {{title}}' --player=spotify)"
		fi
		playerctl play-pause --player=spotify
		;;
	--next|-n)
		playerctl next --player=spotify
		$NOTIFICATION "Spotify Next" "$(playerctl metadata --format '{{artist}} - {{title}}' --player=spotify)"
		;;
	--previous|-p)
		playerctl previous --player=spotify
		$NOTIFICATION "Spotify Previous" "$(playerctl metadata --format '{{artist}} - {{title}}' --player=spotify)"
		;;
	--current|-c)
		$NOTIFICATION "Spotify Song Info" "$(playerctl metadata --format '{{artist}} - {{title}}' --player=spotify)"
		;;
	--volume-up|-vu)
		VOLUME=$(awk "BEGIN {v=$(playerctl --player=spotify volume)+0.05; if(v>1) v=1; print v}")
		playerctl --player=spotify volume $VOLUME &&
		$NOTIFICATION "Spotify Volume Up" "Volume: $(awk "BEGIN {print int($VOLUME*100)}")% ↑"
		;;
	--volume-down|-vd)
		VOLUME=$(awk "BEGIN {v=$(playerctl --player=spotify volume)-0.05; if(v>1) v=1; print v}")
		playerctl --player=spotify volume $VOLUME &&
		$NOTIFICATION "Spotify Volume Down" "Volume: $(awk "BEGIN {print int($VOLUME*100)}")% ↓"
		;;

	# Using dbus
	--dbus-playpause)
		dbus-send \
			--print-reply \
			--dest=org.mpris.MediaPlayer2.spotify \
			/org/mpris/MediaPlayer2 \
			org.mpris.MediaPlayer2.Player.PlayPause
		;;
	--dbus-next)
		dbus-send \
			--print-reply \
			--dest=org.mpris.MediaPlayer2.spotify \
			/org/mpris/MediaPlayer2 \
			org.mpris.MediaPlayer2.Player.Next
		;;
	--dbus-previous)
		dbus-send \
			--print-reply \
			--dest=org.mpris.MediaPlayer2.spotify \
			/org/mpris/MediaPlayer2 \
			org.mpris.MediaPlayer2.Player.Previous
		;;
	--dbus-current)
		qdbus6 \
			--literal org.mpris.MediaPlayer2.spotify \
			/org/mpris/MediaPlayer2 \
			org.freedesktop.DBus.Properties.Get \
			org.mpris.MediaPlayer2.Player \
			Metadata
		;;

	*)
		usage
		exit 1
		;;
esac
