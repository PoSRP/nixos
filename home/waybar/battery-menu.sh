#!/usr/bin/env bash

set -uo pipefail

choice=$(printf 'Full charge\n' \
    | rofi -dmenu -i -p '' -no-fixed-num-lines \
        -theme "$HOME/.config/rofi/popover.rasi" \
        -theme-str 'inputbar { enabled: false; }' \
        -me-accept-entry '!MousePrimary' \
    || true)

case "$choice" in
    "Full charge")
        if sudo tlp fullcharge BAT0; then
            notify-send -t 4000 "Battery" "Full charge enabled. Replug the charger if it is not charging."
        else
            notify-send -u critical "Battery" "Full charge failed."
        fi
        ;;
esac
