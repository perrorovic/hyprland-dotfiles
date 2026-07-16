#!/usr/bin/env bash

# phitab-sunshine.sh: create the phitab-headless output then run sunshine
# will clean up hyprctl monitors and sunshine when the script is exiting
# requirement: display knowledge on hyprland.conf for phitab-headless

cleanup() {
  trap - EXIT INT TERM
  pkill -x sunshine
  hyprctl output remove phitab-headless
}
trap cleanup EXIT INT TERM

hyprctl output create headless phitab-headless
sunshine
