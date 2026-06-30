#!/usr/bin/env bash

SENTINEL="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprpaper-include-private"

if [[ -e "$SENTINEL" ]]; then
    text="●"
    class="private"
else
    text="○"
    class="default"
fi

printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
