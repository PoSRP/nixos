#!/usr/bin/env bash

set -uo pipefail

TMPFILE="/tmp/waybar-network"

iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')

if [[ -z "$iface" || ! -d "/sys/class/net/$iface" ]]; then
    jq -nc '{text:"disconnected", tooltip:"no default route", class:"disconnected"}'
    exit 0
fi

rx=$(<"/sys/class/net/$iface/statistics/rx_bytes")
tx=$(<"/sys/class/net/$iface/statistics/tx_bytes")
now=$EPOCHREALTIME

rate_rx=0
rate_tx=0
if [[ -f $TMPFILE ]]; then
    read -r prev_iface prev_rx prev_tx prev_time < "$TMPFILE"
    if [[ "$prev_iface" == "$iface" ]]; then
        read -r rate_rx rate_tx < <(awk \
            -v cr="$rx" -v pr="$prev_rx" \
            -v ct="$tx" -v pt="$prev_tx" \
            -v n="$now" -v pn="$prev_time" \
            'BEGIN{e=n-pn; if(e>0) printf "%.0f %.0f", (cr-pr)/e, (ct-pt)/e; else print "0 0"}')
    fi
fi
printf '%s %s %s %s\n' "$iface" "$rx" "$tx" "$now" > "$TMPFILE"

fmt_iec() { numfmt --to=iec-i --suffix=B --format='%.2f' "$1"; }

session_rx_h=$(fmt_iec "$rx")
session_tx_h=$(fmt_iec "$tx")
rate_rx_h=$(numfmt --to=si --suffix=bit/s --format='%.1f' "$((rate_rx * 8))")
rate_tx_h=$(numfmt --to=si --suffix=bit/s --format='%.1f' "$((rate_tx * 8))")

ipinfo=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {print $2; exit}')

case $iface in
    wl*)
        essid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
        text="${essid:-wifi}"
        ;;
    *)
        text="connected"
        ;;
esac

traffic_block=""
if command -v vnstat >/dev/null 2>&1; then
    vstats=$(vnstat -i "$iface" --json 2>/dev/null)
    if [[ -n "$vstats" ]] && jq -e '.interfaces[0].traffic.day | length > 0' <<<"$vstats" >/dev/null 2>&1; then
        read -r ty tm td < <(date +'%Y %-m %-d')
        cutoff7=$(date -d '6 days ago' +%Y%m%d)
        cutoff30=$(date -d '29 days ago' +%Y%m%d)
        today=$(jq --argjson y "$ty" --argjson m "$tm" --argjson d "$td" '
            .interfaces[0].traffic.day
            | map(select(.date.year==$y and .date.month==$m and .date.day==$d))
            | .[0] // {rx:0,tx:0} | .rx + .tx' <<<"$vstats")
        last7=$(jq --argjson c "$cutoff7" '
            [.interfaces[0].traffic.day[]
             | select((.date.year*10000 + .date.month*100 + .date.day) >= $c)
             | (.rx + .tx)] | add // 0' <<<"$vstats")
        last30=$(jq --argjson c "$cutoff30" '
            [.interfaces[0].traffic.day[]
             | select((.date.year*10000 + .date.month*100 + .date.day) >= $c)
             | (.rx + .tx)] | add // 0' <<<"$vstats")
        month=$(jq --argjson y "$ty" --argjson m "$tm" '
            .interfaces[0].traffic.month
            | map(select(.date.year==$y and .date.month==$m))
            | .[0] // {rx:0,tx:0} | .rx + .tx' <<<"$vstats")
        traffic_block=$(printf "\nTraffic\nToday:  %s\n7-day:  %s\n30-day: %s\nMonth:  %s" \
            "$(fmt_iec "$today")" "$(fmt_iec "$last7")" \
            "$(fmt_iec "$last30")" "$(fmt_iec "$month")")
    fi
fi

tooltip=$(printf "↑%s ↓%s\nSession: ↑%s ↓%s\n%s: %s%s" \
    "$rate_tx_h" "$rate_rx_h" \
    "$session_tx_h" "$session_rx_h" \
    "$iface" "$ipinfo" "$traffic_block")

jq -nc --arg text "$text" --arg tooltip "$tooltip" \
    '{text:$text, tooltip:$tooltip, class:"connected"}'
