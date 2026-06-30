#!/usr/bin/env bash

set -uo pipefail

WALLPAPER_DIR="$HOME/.wallpapers"
ROTATION_INTERVAL=30

get_monitors() {
    hyprctl monitors -j | jq -r '.[].name'
}

get_current_wallpaper() {
    hyprctl hyprpaper listactive 2>/dev/null \
        | awk -F' = ' 'NF == 2 {print $2; exit}'
}

get_next_wallpaper() {
    local current="${1:-}"
    local wallpapers=() candidates=()
    local search_dirs=("$WALLPAPER_DIR")

    local sentinel="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprpaper-include-private"
    if [[ -e "$sentinel" && -d "$WALLPAPER_DIR/private" ]]; then
        search_dirs+=("$WALLPAPER_DIR/private")
    fi

    while IFS= read -r file; do
        wallpapers+=("$file")
        [[ "$file" == "$current" ]] || candidates+=("$file")
    done < <(
        find -L "${search_dirs[@]}" -maxdepth 1 -type f \( \
            -iname "*.jpg" -o \
            -iname "*.jpeg" -o \
            -iname "*.png" -o \
            -iname "*.webp" \
        \)
    )

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        echo "Error: no wallpapers found in:" >&2
        echo "  $WALLPAPER_DIR" >&2
        exit 1
    fi

    if [[ ${#candidates[@]} -eq 0 ]]; then
        return 1
    fi

    printf '%s\n' "${candidates[@]}" | shuf -n 1
}

apply_wallpaper() {
    local wallpaper="$1"

    echo "Applying wallpaper:"
    echo "  $wallpaper"

    hyprctl hyprpaper preload "$wallpaper"
    while IFS= read -r monitor; do
        [[ -z "$monitor" ]] && continue
        echo "  -> $monitor"
        hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
    done < <(get_monitors)
}

ensure_hyprpaper() {
    if ! pgrep -x hyprpaper >/dev/null; then
        echo "Starting hyprpaper..."
        hyprpaper &
    fi

    local i=0
    until hyprctl hyprpaper listloaded >/dev/null 2>&1; do
        sleep 0.5
        (( i++ )) || true
        if [[ $i -ge 20 ]]; then
            echo "Error: hyprpaper IPC did not become ready after 10s"
            return 1
        fi
    done
}

rotate_once() {
    ensure_hyprpaper

    local current wallpaper
    current=$(get_current_wallpaper)

    if ! wallpaper=$(get_next_wallpaper "$current"); then
        echo "Only current wallpaper available, skipping"
        return 0
    fi

    apply_wallpaper "$wallpaper"
}

# Script work starts here

for cmd in hyprctl jq find shuf; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: missing dependency: $cmd"
        exit 1
    fi
done

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: wallpaper directory does not exist:"
    echo "  $WALLPAPER_DIR"
    exit 1
fi

if [[ "${1:-}" == "once" ]]; then
    rotate_once
else
    echo "Starting wallpaper rotation every $ROTATION_INTERVAL s"
    trap 'echo; echo "Exiting..."; exit 0' SIGINT SIGTERM
    while true; do
        rotate_once
        sleep "$ROTATION_INTERVAL"
    done
fi
