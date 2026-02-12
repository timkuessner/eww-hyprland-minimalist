#!/bin/bash
get_network() {
  state=$(nmcli -t -f STATE general | head -n1)
  if [ "$state" != "connected" ]; then
    echo "{\"connected\": false}"
    return
  fi
  active=$(nmcli -t -f DEVICE,TYPE,STATE device | grep ":connected" | head -n1)
  device=$(echo "$active" | cut -d: -f1)
  type=$(echo "$active" | cut -d: -f2)
  
  if [ "$type" = "wifi" ]; then
    ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | grep "^yes" | cut -d: -f2)
    signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep "^\*" | cut -d: -f2)
    echo "{\"connected\": true, \"type\": \"wifi\", \"ssid\": \"$ssid\", \"signal\": $signal}"
  else
    echo "{\"connected\": true, \"type\": \"$type\"}"
  fi
}

get_network

stdbuf -o0 nmcli monitor | while read -r _; do
  get_network
done