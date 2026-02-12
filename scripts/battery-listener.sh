#!/bin/bash

BAT="BAT0"
AC="ADP1"
POLL_INTERVAL=5

get_battery() {
  capacity=$(cat /sys/class/power_supply/$BAT/capacity)
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

last_capacity=$(cat /sys/class/power_supply/$BAT/capacity)
last_ac=$(cat /sys/class/power_supply/$AC/online 2>/dev/null)

(
  while true; do
    capacity=$(cat /sys/class/power_supply/$BAT/capacity)
    ac_online=$(cat /sys/class/power_supply/$AC/online 2>/dev/null)

    if [ "$capacity" != "$last_capacity" ] || [ "$ac_online" != "$last_ac" ]; then
      get_battery
      last_capacity=$capacity
      last_ac=$ac_online
    fi

    sleep $POLL_INTERVAL
  done
) &

stdbuf -o0 udevadm monitor --udev --subsystem-match=power_supply |
while read -r line; do
  if echo "$line" | grep -qE "$BAT|$AC"; then
    get_battery
  fi
done
