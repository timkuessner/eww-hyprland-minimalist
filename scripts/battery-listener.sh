#!/bin/bash
get_battery() {
  capacity=$(cat /sys/class/power_supply/BAT0/capacity)
  status=$(cat /sys/class/power_supply/BAT0/status)
  echo "{\"capacity\": $capacity, \"status\": \"$status\"}"
}

get_battery

stdbuf -o0 udevadm monitor --udev --subsystem-match=power_supply | \
while read -r line; do
  if echo "$line" | grep -q "BAT0"; then
    get_battery
  fi
done