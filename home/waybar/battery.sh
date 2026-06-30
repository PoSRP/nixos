#!/usr/bin/env bash

set -uo pipefail

BAT=""
for _d in /sys/class/power_supply/BAT*; do
    [[ -d "$_d" ]] && BAT="$_d" && break
done

if [[ -z "$BAT" ]]; then
    printf '{"text":""}\n'
    exit 0
fi

capacity=$(<"$BAT/capacity")
status=$(<"$BAT/status")
voltage_uv=$(<"$BAT/voltage_now")

power_uw=0
if [[ -f $BAT/power_now ]]; then
    power_uw=$(<"$BAT/power_now")
elif [[ -f $BAT/current_now ]]; then
    current_ua=$(<"$BAT/current_now")
    power_uw=$(( current_ua * voltage_uv / 1000000 ))
fi

ef="" efd=""
if [[ -f $BAT/energy_full && -f $BAT/energy_full_design ]]; then
    ef=$(<"$BAT/energy_full"); efd=$(<"$BAT/energy_full_design")
elif [[ -f $BAT/charge_full && -f $BAT/charge_full_design ]]; then
    ef=$(<"$BAT/charge_full"); efd=$(<"$BAT/charge_full_design")
fi

health=""
if [[ -n $ef && -n $efd && $efd -gt 0 ]]; then
    health=$(awk -v a="$ef" -v b="$efd" 'BEGIN{printf "%.1f", a*100/b}')
fi

voltage_v=$(awk -v v="$voltage_uv" 'BEGIN{printf "%.2f", v/1000000}')
power_w=$(awk -v p="$power_uw" 'BEGIN{printf "%.1f", p/1000000}')

case $status in
    Charging)       sign="+"; classes='["charging"]' ;;
    Full)           sign="="; classes='["full"]' ;;
    "Not charging") sign="="; classes='["plugged"]' ;;
    *)
        sign="-"; classes='["discharging"]'
        warning_level=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null \
            | awk '/warning-level:/ {print $2; exit}')
        case $warning_level in
            critical|action) classes='["discharging","critical"]' ;;
            low)             classes='["discharging","warning"]' ;;
        esac
        ;;
esac

text=$(printf "%s%s%% %sW" "$sign" "$capacity" "$power_w")

if [[ -n $health ]]; then
    tooltip=$(printf "Status: %s\nPower: %s W\nVoltage: %s V\nHealth: %s%%" \
        "$status" "$power_w" "$voltage_v" "$health")
else
    tooltip=$(printf "Status: %s\nPower: %s W\nVoltage: %s V" \
        "$status" "$power_w" "$voltage_v")
fi

jq -nc --arg text "$text" --arg tooltip "$tooltip" --argjson class "$classes" \
    '{text:$text, tooltip:$tooltip, class:$class}'
