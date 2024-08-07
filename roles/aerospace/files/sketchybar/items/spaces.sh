#!/usr/bin/env bash

PLUGIN_DIR="$CONFIG_DIR/plugins"

sketchybar --add event aerospace_workspace_change
for monitorID in $(aerospace list-monitors --format '%{monitor-id}'); do
  realMonitorID="$("${PLUGIN_DIR}/get_real_monitor_id.sh" "$monitorID")"
  for sid in $(aerospace list-workspaces --monitor "$monitorID"); do
    display=$realMonitorID
    # The macOS bash is still v3 and doesn't know about mapfile
    # mapfile -t windowsOnWorkspace < <(aerospace list-windows --workspace "$sid")
    IFS=$'\n' read -r -d '' -a windowsOnWorkspace < <(aerospace list-windows --workspace "$sid" && printf '\0')
    # If there the workspace is empty
    if ((!${#windowsOnWorkspace[@]})); then
      icon_strip=''
      display=0
    else
      icon_strip="$("${PLUGIN_DIR}/get_icon_strip.sh" "$sid")"
    fi
    name="space.$sid"
    space=(
      background.color=0x44ffffff
      background.corner_radius=5
      background.height=20
      label.y_offset=-1
      label.font="sketchybar-app-font:Regular:18.0"
      background.drawing=off
      click_script="aerospace workspace $sid"
      script="${PLUGIN_DIR}/aerospace.sh $sid"
      icon="$sid"
      display="$display"
      label="$icon_strip"
    )
    sketchybar --add item "$name" left \
      --set "$name" "${space[@]}" \
      --subscribe "$name" aerospace_workspace_change
  done
done

# vim: ft=bash.jinja2
