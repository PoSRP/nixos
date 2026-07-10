#!/usr/bin/env bash

set -uo pipefail

IO_STATE="/tmp/waybar-disk-io"
SMART_CACHE="/tmp/waybar-disk-smart"
SMART_TTL=60
SMARTCTL=$(readlink -f "$(command -v smartctl)" 2>/dev/null || true)

CURR_TIME=$EPOCHREALTIME

# Resolve the physical disk backing '/'. Cached to $IO_STATE line 1.
if [ -f "$IO_STATE" ]; then
    read -r DISK PREV_READ PREV_WRITE PREV_TIME PREV_SR PREV_SW < "$IO_STATE"
else
    DEV_NODE=$(readlink -f "$(df --output=source / | tail -1)")
    DEV_NAME=$(basename "$DEV_NODE")
    if [ -d "/sys/class/block/$DEV_NAME/slaves" ] && [ -n "$(ls -A "/sys/class/block/$DEV_NAME/slaves" 2>/dev/null)" ]; then
        SLAVE=$(ls "/sys/class/block/$DEV_NAME/slaves/" | head -1)
        DISK=$(basename "$(readlink -f "/sys/class/block/$SLAVE/..")")
    else
        DISK=$(basename "$(readlink -f "/sys/class/block/$DEV_NAME/..")")
    fi
fi

# SMART target device: NVMe controller (e.g. nvme0) vs SATA block device.
case "$DISK" in
    nvme*) SMART_DEV="/dev/${DISK%n[0-9]*}" ;;
    *)     SMART_DEV="/dev/$DISK" ;;
esac

# Fast: usage from df.
df_line=$(df -B1 --output=used,size / | tail -1)
read -r used_b total_b <<< "$df_line"
used_gib=$(awk -v v="$used_b"  'BEGIN{printf "%.1f", v/1024/1024/1024}')
total_gib=$(awk -v v="$total_b" 'BEGIN{printf "%.1f", v/1024/1024/1024}')
pct=$(awk -v u="$used_b" -v t="$total_b" 'BEGIN{printf "%.0f", u*100/t}')

# Fast: temperature from hwmon. Prefer nvme; fall back to first sensor
# whose device path contains our DISK.
temp_c=""
for hwmon in /sys/class/hwmon/hwmon*; do
    [[ -r "$hwmon/name" ]] || continue
    name=$(<"$hwmon/name")
    dev_path=$(readlink -f "$hwmon/device" 2>/dev/null || true)
    if [[ "$name" == "nvme" || "$dev_path" == *"$DISK"* ]]; then
        for t in "$hwmon"/temp*_input; do
            [[ -r "$t" ]] || continue
            temp_c=$(awk -v v="$(<"$t")" 'BEGIN{printf "%.0f", v/1000}')
            break
        done
        [[ -n "$temp_c" ]] && break
    fi
done
[[ -z "$temp_c" ]] && temp_c="n/a"

# Slow: smartctl cache. Refresh in background when stale.
if [ -f "$SMART_CACHE" ]; then
    cache_age=$(( $(date +%s) - $(stat -c%Y "$SMART_CACHE") ))
else
    cache_age=999999
fi
if (( cache_age > SMART_TTL )) && [ -n "$SMARTCTL" ]; then
    (
        sudo -n "$SMARTCTL" -a "$SMART_DEV" 2>/dev/null > "${SMART_CACHE}.tmp" \
            && mv "${SMART_CACHE}.tmp" "$SMART_CACHE"
    ) &
    disown 2>/dev/null || true
fi

model="n/a"; health="n/a"; power_on="n/a"; written="n/a"
if [ -s "$SMART_CACHE" ]; then
    model=$(awk -F: '/^Model Number/ {sub(/^[ \t]+/, "", $2); print $2; exit}'      "$SMART_CACHE")
    [[ -z "$model" ]] && \
        model=$(awk -F: '/^Device Model/ {sub(/^[ \t]+/, "", $2); print $2; exit}'  "$SMART_CACHE")
    health=$(awk -F: '/^SMART overall-health/ {sub(/^[ \t]+/, "", $2); print $2; exit}' "$SMART_CACHE")
    power_on=$(awk -F: '/^Power On Hours/ {gsub(/[^0-9]/, "", $2); print $2; exit}' "$SMART_CACHE")
    written=$(awk -F: '/^Data Units Written/ {
        if (match($2, /\[[^]]+\]/)) print substr($2, RSTART+1, RLENGTH-2); exit
    }' "$SMART_CACHE")
    [[ -z "$model"    ]] && model="n/a"
    [[ -z "$health"   ]] && health="n/a"
    [[ -z "$power_on" ]] && power_on="n/a"
    [[ -z "$written"  ]] && written="n/a"
fi

# Fast: IO throughput from /proc/diskstats.
io_out=$(awk -v disk="$DISK" -v ct="$CURR_TIME" \
    -v pr="${PREV_READ-}" -v pw="${PREV_WRITE-}" -v pt="${PREV_TIME:-0}" \
    -v sr="${PREV_SR-}" -v sw="${PREV_SW-}" \
    '$3 == disk {
        cr = $6; cw = $10
        if (pr == "" || cr < pr || cw < pw) {
            printf "%s %s %s %s %s %s\n", disk, cr, cw, ct, 0, 0
            printf "|↑--- ↓---"
            exit
        }
        elapsed = ct - pt
        if (elapsed <= 0) {
            printf "|↑--- ↓---"
            exit
        }
        instant_r = (cr - pr) * 512 / 1048576 / elapsed
        instant_w = (cw - pw) * 512 / 1048576 / elapsed
        alpha = 0.5
        smooth_r = (sr == "") ? instant_r : alpha * instant_r + (1 - alpha) * sr
        smooth_w = (sw == "") ? instant_w : alpha * instant_w + (1 - alpha) * sw
        printf "%s %s %s %s %s %s\n", disk, cr, cw, ct, smooth_r, smooth_w
        printf "|↑%.1f ↓%.1f", smooth_r, smooth_w
        exit
    }' /proc/diskstats)

state_line="${io_out%%|*}"
io_text="${io_out#*|}"
[[ -n "$state_line" ]] && printf "%s\n" "$state_line" > "$IO_STATE"

text=$(printf "%s%% %s" "$pct" "$io_text")

tooltip=$(printf "Model:     %s\nCapacity:  %s GiB / %s GiB (%s%%)\nTemp:      %s°C\nHealth:    %s\nPower-on:  %s h\nWritten:   %s" \
    "$model" "$used_gib" "$total_gib" "$pct" "$temp_c" "$health" "$power_on" "$written")

jq -nc --arg text "$text" --arg tooltip "$tooltip" '{text:$text, tooltip:$tooltip}'
