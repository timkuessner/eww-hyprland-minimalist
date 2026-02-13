#!/bin/bash

# Function to get current bluetooth status
get_bluetooth_status() {
    # Check if bluetooth is powered on
    powered=$(bluetoothctl show | grep "Powered: yes" 2>/dev/null)
    
    # Count connected devices
    connected_count=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
    
    if [[ -n "$powered" && $connected_count -gt 0 ]]; then
        echo '{"powered":true,"connected":true}'
    elif [[ -n "$powered" ]]; then
        echo '{"powered":true,"connected":false}'
    else
        echo '{"powered":false,"connected":false}'
    fi
}

# Output initial status
get_bluetooth_status

# Monitor D-Bus for bluetooth property changes
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path_namespace='/org/bluez'" 2>/dev/null | \
while read -r line; do
    # On any bluetooth property change, output new status
    if [[ "$line" == *"org.bluez"* ]] || [[ "$line" == *"Connected"* ]] || [[ "$line" == *"Powered"* ]]; then
        get_bluetooth_status
    fi
done