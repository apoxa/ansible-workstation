#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/icon_map.sh"

WS="$1"
icon_strip=()
while read -r app; do
  __icon_map "$app"
  icon_strip+=("${icon_result/iterm/terminal}")
done < <(aerospace list-windows --workspace "$WS" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}' | sort -u)
echo "${icon_strip[@]}"

# vim: ft=bash.jinja2
