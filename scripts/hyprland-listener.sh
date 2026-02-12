#!/bin/bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

get_hypr_info() {
  class=$(hyprctl activewindow -j | jq -r '.class // "Desktop"')
  active_ws=$(hyprctl activeworkspace -j | jq -r '.id // 0')
  workspaces=$(hyprctl workspaces -j | jq -c '[.[] | .id] | sort')
  max_ws=$(echo "$workspaces" | jq 'if length > 0 then max else 5 end | if . < 5 then 5 else . end')
  workspace_array=$(seq 1 $max_ws | jq -s -c '.')
  
  echo "{\"class\": \"$class\", \"active_workspace\": $active_ws, \"workspaces\": $workspaces, \"workspace_array\": $workspace_array}"
}

get_hypr_info

stdbuf -o0 socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
  event=$(echo "$line" | cut -d '>' -f1)
  case $event in
    workspace|workspacev2|activewindow|activewindowv2|createworkspace|destroyworkspace)
      get_hypr_info
      ;;
  esac
done