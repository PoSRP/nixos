#!/usr/bin/env bash
# Polls battery state. When percentage transitions downward through THRESHOLD
# while on battery, spawns the countdown alert. The "transition" semantics mean
# that after a poweroff + power-on at low battery you can keep running down to
# upower's safety-net action without re-triggering the alert.

set -uo pipefail

THRESHOLD=15
POLL=15
ALERT_SCRIPT="$HOME/.config/hypr/battery-critical-alert.sh"
ALERT_CLASS="battery-critical-alert"

bat_pct() {
    local f
    for f in /sys/class/power_supply/BAT*/capacity; do
        [[ -e "$f" ]] || continue
        cat "$f"
        return
    done
}

on_battery() {
    local f
    for f in /sys/class/power_supply/A{C,DP}*/online; do
        [[ -e "$f" ]] || continue
        [[ "$(cat "$f" 2>/dev/null)" == "1" ]] && return 1
    done
    return 0
}

alert_running() {
    pgrep -f "$ALERT_SCRIPT" >/dev/null 2>&1
}

last_pct=$(bat_pct)

while sleep "$POLL"; do
    cur=$(bat_pct)
    if [[ -z "$cur" || -z "$last_pct" ]]; then
        last_pct=$cur
        continue
    fi

    if (( last_pct > THRESHOLD )) && (( cur <= THRESHOLD )) \
        && on_battery && ! alert_running; then
        # Drop the focused window out of fullscreen so the alert can overlay it.
        hyprctl dispatch fullscreenstate 0 0 >/dev/null 2>&1 || true
        kitty --class "$ALERT_CLASS" --title "Battery Critical" \
            "$ALERT_SCRIPT" &
    fi
    last_pct=$cur
done
