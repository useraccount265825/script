#!/bin/bash

# Define the directory containing the OpenVPN configuration files
CONFIG_DIR="$HOME/Downloads"

# Function to find all .ovpn files in the directory
function find_ovpn_files {
    OVPN_FILES=("$CONFIG_DIR"/*.ovpn)
    if [ ${#OVPN_FILES[@]} -eq 0 ]; then
        echo "Error: No .ovpn files found in $CONFIG_DIR."
        exit 1
    fi
}

# Function to start OpenVPN with a random configuration
function start_vpn {
    find_ovpn_files
    RANDOM_FILE=${OVPN_FILES[RANDOM % ${#OVPN_FILES[@]}]}
    echo "Starting OpenVPN with configuration: $RANDOM_FILE"
    sudo openvpn --config "$RANDOM_FILE" &
    VPN_PID=$!
}

# Function to display the current IP address
function display_ip {
    CURRENT_IP=$(curl -s ifconfig.me)
    echo -e "\nCurrent IP Address: $CURRENT_IP"
}

# Function to handle cleanup on exit
function cleanup {
    echo -e "\nDisconnecting OpenVPN..."
    if kill -0 $VPN_PID 2>/dev/null; then
        sudo kill $VPN_PID
        wait $VPN_PID 2>/dev/null
        echo "OpenVPN has stopped."
    fi
}

# Trap SIGINT (Ctrl + C) to call cleanup
trap 'cleanup' SIGINT

# Start the first VPN connection
start_vpn

# Display the current IP address
display_ip

# Wait for the OpenVPN process
wait $VPN_PID

# After the VPN session ends, display the current IP address again
display_ip
