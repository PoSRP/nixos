#!/usr/bin/env bash

set -uo pipefail

sensors_json=$(sensors -j 2>/dev/null || echo '{}')

temps=$(jq -c '
    [
        to_entries[] |
        (.key | split("-") | .[0:-2] | join("-")) as $chip |
        .value |
        to_entries[] |
        select(.value | type == "object") |
        .key as $label |
        .value |
        to_entries[] |
        select(.key | test("^temp[0-9]+_input$")) |
        select(.value > 0) |
        {chip: $chip, label: $label, value: .value}
    ]
' <<<"$sensors_json")

if [[ -z $temps || $temps == "[]" ]]; then
    printf '{"text":""}\n'
    exit 0
fi

max_temp=$(jq -r 'map(.value) | max | floor' <<<"$temps")

tooltip=$(jq -r '
    def ljust($w): . + (" " * ($w - length));
    def rjust($w): (" " * ($w - length)) + .;
    sort_by(.chip + " " + .label) |
    map({prefix: "[\(.chip)] \(.label):", val: "\(.value | floor) °C"}) |
    (map(.prefix | length) | max) as $pw |
    (map(.val    | length) | max) as $vw |
    map((.prefix | ljust($pw)) + "  " + (.val | rjust($vw))) |
    "<tt>" + join("\n") + "</tt>"
' <<<"$temps")

text="${max_temp}°C"

jq -nc --arg text "$text" --arg tooltip "$tooltip" \
    '{text:$text, tooltip:$tooltip}'
