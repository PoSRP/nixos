#!/usr/bin/env bash
# Countdown UI launched inside a kitty window. Aborts cleanly if AC power is
# restored mid-countdown; otherwise issues systemctl poweroff.

set -uo pipefail

COUNTDOWN=120

on_battery() {
    local f
    for f in /sys/class/power_supply/A{C,DP}*/online; do
        [[ -e "$f" ]] || continue
        [[ "$(cat "$f" 2>/dev/null)" == "1" ]] && return 1
    done
    return 0
}

bat_pct() {
    local f
    for f in /sys/class/power_supply/BAT*/capacity; do
        [[ -e "$f" ]] || continue
        cat "$f"
        return
    done
}

while (( COUNTDOWN > 0 )); do
    if ! on_battery; then
        clear
        printf '\n\n  AC power restored.\n  Poweroff aborted.\n\n'
        sleep 3
        exit 0
    fi
    clear
    printf '\n\n  BATTERY CRITICAL  (%s%%)\n\n  Powering off in: %3d seconds\n\n  Plug in AC adapter to abort.\n\n' \
        "$(bat_pct)" "$COUNTDOWN"
    sleep 1
    ((COUNTDOWN--))
done

systemctl poweroff
