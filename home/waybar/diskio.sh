#!/usr/bin/env bash

set -uo pipefail

TMPFILE="/tmp/waybar-diskio"
CURR_TIME=$EPOCHREALTIME

if [ -f "$TMPFILE" ]; then
    read -r DISK PREV_READ PREV_WRITE PREV_TIME PREV_SR PREV_SW < "$TMPFILE"
else
    DEV_NODE=$(readlink -f "$(df --output=source / | tail -1)")
    DEV_NAME=$(basename "$DEV_NODE")
    if [ -d "/sys/class/block/$DEV_NAME/slaves" ]; then
        SLAVE=$(ls "/sys/class/block/$DEV_NAME/slaves/" | head -1)
        DISK=$(basename "$(readlink -f "/sys/class/block/$SLAVE/..")")
    else
        DISK=$(basename "$(readlink -f "/sys/class/block/$DEV_NAME/..")")
    fi
fi

awk -v disk="$DISK" -v ct="$CURR_TIME" \
    -v pr="${PREV_READ-}" -v pw="${PREV_WRITE-}" -v pt="${PREV_TIME:-0}" \
    -v sr="${PREV_SR-}" -v sw="${PREV_SW-}" \
    -v tmpfile="$TMPFILE" \
    '$3 == disk {
        cr = $6; cw = $10
        if (pr == "" || cr < pr || cw < pw) { print disk, cr, cw, ct, 0, 0 > tmpfile; print "↑--- ↓---"; exit }
        elapsed = ct - pt
        if (elapsed <= 0) { print "↑--- ↓---"; exit }
        instant_r = (cr - pr) * 512 / 1048576 / elapsed
        instant_w = (cw - pw) * 512 / 1048576 / elapsed
        alpha = 0.5
        smooth_r = (sr == "") ? instant_r : alpha * instant_r + (1 - alpha) * sr
        smooth_w = (sw == "") ? instant_w : alpha * instant_w + (1 - alpha) * sw
        print disk, cr, cw, ct, smooth_r, smooth_w > tmpfile
        printf "↑%.1f ↓%.1f\n", smooth_r, smooth_w
        exit
    }' /proc/diskstats
