#!/usr/bin/env bash

PLUGIN_DIR="$CONFIG_DIR/plugins"

rewriteSketchybar() {
  local ws=$1
  icon_strip="$("$PLUGIN_DIR"/get_icon_strip.sh "$ws")"
  monitorID=$(aerospace list-monitors --focused --format '%{monitor-id}')
  realMonitorID="$("$PLUGIN_DIR"/get_real_monitor_id.sh "$monitorID")"
  sketchybar --set "space.$ws" label="$icon_strip" display="$realMonitorID"
}

if [[ "$WORKSPACE_MOVE" == "true" ]]; then
  ws=$(aerospace list-workspaces --focused)
  if [[ "$NAME" == "space.$ws" ]]; then
    newMonitorID=$(aerospace list-monitors --focused --format '%{monitor-id}')
    sketchybar --set "$NAME" display="$("$PLUGIN_DIR"/get_real_monitor_id.sh "$newMonitorID")"
  fi
elif [[ "$FOCUS_CHANGE" == "true" ]]; then
  FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused)"
  if [[ "$NAME" = "space.$FOCUSED_WORKSPACE" ]]; then
    rewriteSketchybar "$FOCUSED_WORKSPACE"
  fi
elif [[ -n "$NEW_WS" ]]; then
  if [[ "$NAME" = "space.$NEW_WS" ]]; then
    rewriteSketchybar "$NEW_WS"
  fi
else
  if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "space.$FOCUSED_WORKSPACE" background.drawing=on
    sketchybar --set "space.$PREVIOUS_WORKSPACE" background.drawing=off

    # Run this later to have the background drawing already done.
    rewriteSketchybar "$FOCUSED_WORKSPACE"
  else
    sketchybar --set "$NAME" background.drawing=off
    # If the previous workspace is empty, move it to a non-visible display.
    if [[ "$1" == "$PREVIOUS_WORKSPACE" ]]; then
      if [[ $(aerospace list-windows --workspace "${NAME//*./}" | wc -l) -eq 0 ]]; then
        sketchybar --set "$NAME" display=0 label=""
      fi
    fi
  fi
fi

# vim: ft=bash.jinja2
