#!/bin/bash

# Define the directory containing the OpenVPN configuration files
CONFIG_DIR="$HOME/Downloads"

# Find all .ovpn files in the directory
OVPN_FILES=("$CONFIG_DIR"/*.ovpn)

# Check if there are any .ovpn files
if [ ${#OVPN_FILES[@]} -eq 0 ]; then
    echo "Error: No .ovpn files found in $CONFIG_DIR."
    exit 1
fi

# Pick a random .ovpn file
RANDOM_FILE=${OVPN_FILES[RANDOM % ${#OVPN_FILES[@]}]}

echo "Starting OpenVPN with configuration: $RANDOM_FILE"

# Start OpenVPN in the background
sudo openvpn --config "$RANDOM_FILE" &

# Get the PID of the OpenVPN process
VPN_PID=$!

# Function to display the current IP address
function display_ip {
    CURRENT_IP=$(curl -s ifconfig.me)
    echo "Current IP Address: $CURRENT_IP"
}

# Function to display remaining time (for demonstration, we'll just use a countdown)
function display_remaining_time {
    # Set the duration for the VPN session (in seconds)
    DURATION=3600  # 1 hour
    while [ $DURATION -gt 0 ]; do
        echo "Remaining time: $((DURATION / 60)) minutes and $((DURATION % 60)) seconds"
        sleep 60
        DURATION=$((DURATION - 60))
    done
}

# Start displaying the remaining time and current IP address
display_remaining_time &  # Run in the background
IP_DISPLAY_PID=$!

# Monitor the OpenVPN process
wait $VPN_PID

# Clean up background processes
kill $IP_DISPLAY_PID
echo "OpenVPN has stopped."
