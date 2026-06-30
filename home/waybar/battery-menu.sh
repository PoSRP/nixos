#!/usr/bin/env bash

set -uo pipefail

theme=$(cat <<'EOF'
* {
    bg:     #1e1e2e;
    fg:     #cdd6f4;
    accent: #89b4fa;
    border: #45475a;
}
window {
    location:         northeast;
    anchor:           northeast;
    x-offset:         -4px;
    y-offset:         28px;
    width:            200px;
    background-color: @bg;
    border:           1px;
    border-color:     @border;
    border-radius:    8px;
    padding:          6px;
}
mainbox {
    children: [ listview ];
    spacing:  0;
    padding:  0;
    background-color: transparent;
}
listview {
    columns:          1;
    lines:            5;
    dynamic:          true;
    fixed-height:     false;
    scrollbar:        false;
    spacing:          2px;
    background-color: transparent;
}
element {
    padding:          6px 10px;
    border-radius:    4px;
    background-color: transparent;
    text-color:       @fg;
    cursor:           pointer;
}
element selected {
    background-color: @accent;
    text-color:       @bg;
}
element-text {
    background-color: transparent;
    text-color:       inherit;
    vertical-align:   0.5;
}
EOF
)

choice=$(printf 'Full charge\n' \
    | rofi -dmenu -i -p '' -no-fixed-num-lines -theme-str "$theme" \
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
