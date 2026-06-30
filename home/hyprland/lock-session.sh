#!/usr/bin/env bash

set -uo pipefail

SENTINEL="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprpaper-include-private"

# Force privacy mode off before locking, so the lock background can't reveal
# a private wallpaper.
if [[ -e "$SENTINEL" ]]; then
    rm -f "$SENTINEL"
    ~/.config/hypr/hyprpaper-rotator.sh once
    pkill -RTMIN+8 waybar 2>/dev/null || true
fi

# Pause any MPRIS-aware media (browsers, music/video players) before locking.
playerctl --all-players pause 2>/dev/null || true

# Point hyprlock at the current wallpaper file directly (no screenshot), so
# open windows don't appear in the blurred background.
current_wp=$(hyprctl hyprpaper listactive 2>/dev/null \
    | awk -F' = ' 'NF == 2 {print $2; exit}')
mkdir -p "$HOME/.cache"
if [[ -n "$current_wp" && -f "$current_wp" ]]; then
    ln -sf "$current_wp" "$HOME/.cache/hyprlock-bg"
fi

exec hyprlock
