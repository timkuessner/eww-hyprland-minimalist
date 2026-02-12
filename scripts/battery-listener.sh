#!/bin/bash

BAT="BAT0"
AC="ADP1"

get_battery() {
  capacity=$(cat /sys/class/power_supply/$BAT/capacity)
  bat_status=$(cat /sys/class/power_supply/$BAT/status)
  ac_online=$(cat /sys/class/power_supply/$AC/online 2>/dev/null)

  if [ "$ac_online" = "1" ]; then
    if [ "$capacity" -ge 100 ]; then
      status="Full"
    else
      status="Charging"
    fi
  else
    status="Discharging"
  fi

  echo "{\"capacity\": $capacity, \"status\": \"$status\"}"
}

get_battery

stdbuf -o0 udevadm monitor --udev --subsystem-match=power_supply | \
while read -r line; do
  if echo "$line" | grep -qE "$BAT|$AC"; then
    get_battery
  fi
done
