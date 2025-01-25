#!/bin/bash

# Define the directory containing the OpenVPN configuration files
CONFIG_DIR="/home/$(whoami)/Downloads"

# Find all .ovpn files in the directory
OVPN_FILES=("$CONFIG_DIR"/*.ovpn)

# Check if there are any .ovpn files
if [ ${#OVPN_FILES[@]} -eq 0 ]; then
    echo "Error: No .ovpn files found in $CONFIG_DIR."
    exit 1
fi

# Initialize a variable to keep track of the last used file
LAST_USED_FILE=""

# Function to start OpenVPN with a random configuration
start_vpn() {
    # Pick a random .ovpn file that is not the last used one
    while true; do
        RANDOM_FILE=${OVPN_FILES[RANDOM % ${#OVPN_FILES[@]}]}
        if [[ "$RANDOM_FILE" != "$LAST_USED_FILE" ]]; then
            break
        fi
    done

    echo "Starting OpenVPN with configuration: $RANDOM_FILE"
    sudo openvpn --config "$RANDOM_FILE" --daemon
    LAST_USED_FILE="$RANDOM_FILE"
}

# Start the first VPN connection
start_vpn

# Reconnect every 10 minutes
while true; do
    sleep 600  # Sleep for 10 minutes
    start_vpn
done
