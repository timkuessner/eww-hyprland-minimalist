#!/bin/bash
while true; do
  # Format: Tue Feb 12 15:26
  echo "{\"date\": \"$(date '+%a %b %d')\", \"time\": \"$(date '+%H:%M')\"}"
  sleep 1
done