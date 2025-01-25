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

# Function to display the remaining time
function display_remaining_time {
    DURATION=600  # 10 minutes
    while [ $DURATION -gt 0 ]; do
        echo -ne "Remaining time: $((DURATION / 60)) minutes and $((DURATION % 60)) seconds\033[0K\r"
        sleep 1
        DURATION=$((DURATION - 1))
    done
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

# Function to handle reconnection after a delay
function reconnect_vpn {
    cleanup
    echo "Waiting for 10 seconds before reconnecting..."  # Short wait before reconnecting
    sleep 10
    start_vpn
}

# Trap SIGINT (Ctrl + C) to call cleanup and reconnect
trap 'reconnect_vpn' SIGINT

# Start the first VPN connection
start_vpn

# Display the current IP address
display_ip

# Start displaying the remaining time
display_remaining_time &  # Run in the background
TIME_DISPLAY_PID=$!

# Wait for the OpenVPN process
wait $VPN_PID

# Clean up background processes
kill $TIME_DISPLAY_PID 2>/dev/null

# After the VPN session ends, display the current IP address again
display_ip

# Start the reconnection process
reconnect_vpn
