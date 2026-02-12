#!/bin/bash

SCRIPT_DIR="$HOME/.config/eww/scripts"

find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;
