#!/bin/bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

get_hypr_info() {
  # Get active window class
  class=$(hyprctl activewindow -j | jq -r '.class // "Desktop"')
  
  # Get active workspace ID
  active_ws=$(hyprctl activeworkspace -j | jq -r '.id // 0')
  
  # Get all workspaces with windows
  workspaces=$(hyprctl workspaces -j | jq -c '[.[] | .id] | sort')
  
  echo "{\"class\": \"$class\", \"active_workspace\": $active_ws, \"workspaces\": $workspaces}"
}

# initial state
get_hypr_info

# listen to events
stdbuf -o0 socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
  event=$(echo "$line" | cut -d '>' -f1)
  case $event in
    workspace|workspacev2|activewindow|activewindowv2|createworkspace|destroyworkspace)
      get_hypr_info
      ;;
  esac
done