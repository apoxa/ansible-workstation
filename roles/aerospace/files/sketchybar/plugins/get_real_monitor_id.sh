#!/usr/bin/env bash

MAIN_MONITOR="DELL C3422WE|XG32UQ"

monitors=$(aerospace list-monitors)
monitorsSorted=("$(grep -E "$MAIN_MONITOR" <<<"$monitors")")
monitorsSorted+=("$(grep -Ev "$MAIN_MONITOR" <<<"$monitors")")

printf '%s\n' "${monitorsSorted[@]}" | sed "$1,1!d" | awk '{ print $1 }'

# vim: ft=bash.jinja2
