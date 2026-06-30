#!/usr/bin/env bash

set -euo pipefail

SENTINEL="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprpaper-include-private"

verify_password() {
    local entered
    entered=$(rofi -dmenu -password -p "" -l 0 < /dev/null) || return 1
    [[ -n "$entered" ]] || return 1
    # Validate against the login password via sudo -v, then immediately
    # invalidate the timestamp so this doesn't bleed into normal sudo use.
    if printf '%s\n' "$entered" | sudo -k -S -v -p "" 2>/dev/null; then
        sudo -k 2>/dev/null
        return 0
    fi
    return 1
}

if [[ -e "$SENTINEL" ]]; then
    rm -f "$SENTINEL"
else
    verify_password || exit 0
    touch "$SENTINEL"
fi

# Force a re-roll so switching back to default immediately replaces any
# currently-shown private wallpaper (and you see the change either way).
~/.config/hypr/hyprpaper-rotator.sh once

# Refresh the waybar tile.
pkill -RTMIN+8 waybar 2>/dev/null || true
