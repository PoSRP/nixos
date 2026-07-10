#!/usr/bin/env bash

set -uo pipefail

im=$(fcitx5-remote -n 2>/dev/null || true)

if [[ "$im" == "mozc" ]]; then
    text="JP"
else
    layout=$(hyprctl -j devices 2>/dev/null \
        | jq -r '[.keyboards[] | select(.main == true)][0].active_keymap // ""')
    case "$layout" in
        *Danish*|*Denmark*) text="DK" ;;
        *English*|*US*|*"United States"*) text="US" ;;
        *) text="?" ;;
    esac
fi

jq -nc --arg text "$text" '{text:$text}'
