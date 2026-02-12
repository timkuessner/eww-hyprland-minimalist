#!/bin/bash
while true; do
  echo "{\"date\": \"$(date '+%a %b %d')\", \"time\": \"$(date '+%H:%M')\"}"
  sleep 1
done