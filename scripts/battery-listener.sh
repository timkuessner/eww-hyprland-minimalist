#!/bin/bash
get_battery() {
  capacity=$(cat /sys/class/power_supply/BAT0/capacity)
  status=$(cat /sys/class/power_supply/BAT0/status)
  echo "{\"capacity\": $capacity, \"status\": \"$status\"}"
}

# initial state
get_battery

# force unbuffered output
stdbuf -o0 udevadm monitor --udev --subsystem-match=power_supply | \
while read -r line; do
  if echo "$line" | grep -q "BAT0"; then
    get_battery
  fi
done