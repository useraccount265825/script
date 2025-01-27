#!/bin/bash

# Define the directory containing the OpenVPN configuration files
CONFIG_DIR="$HOME/Downloads"

# Define the VPN credentials
USERNAME="vpnbook"

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

    # Prompt for the password
    read -sp "Enter your VPNBook password: " PASSWORD
    echo

    # Create a temporary file for the credentials
    CREDENTIALS_FILE=$(mktemp)
    echo "$USERNAME" > "$CREDENTIALS_FILE"
    echo "$PASSWORD" >> "$CREDENTIALS_FILE"

    # Start OpenVPN with the credentials file
    sudo openvpn --config "$RANDOM_FILE" --auth-user-pass "$CREDENTIALS_FILE" &
    VPN_PID=$!

    # Clean up the credentials file after starting OpenVPN
    trap 'rm -f "$CREDENTIALS_FILE"' EXIT
}

# Function to display the current IP address
function display_ip {
    CURRENT_IP=$(curl -s ifconfig.me)
    echo -e "\nCurrent IP Address: $CURRENT_IP"
}

# Function to fetch and display the VPN-assigned IP address
function fetch_vpn_ip {
    # Wait for a moment to ensure the VPN connection is established
    sleep 5  # Adjust this if necessary
    VPN_IP=$(curl -s ifconfig.me)
    echo -e "\nVPN Assigned IP Address: $VPN_IP"
}

# Function to handle cleanup on exit
function cleanup {
    echo -e "\nDisconnecting OpenVPN..."
    if kill -0 $VPN_PID 2>/dev/null; then
        sudo kill $VPN_PID
        sleep 2  # Wait for a moment to allow graceful shutdown
        if kill -0 $VPN_PID 2>/dev/null; then
            echo "OpenVPN did not stop gracefully, forcing termination..."
            sudo kill -SIGKILL $VPN_PID
        fi
        wait $VPN_PID 2>/dev/null
        echo "OpenVPN has stopped."
    fi
}

# Trap SIGINT (Ctrl + C) to call cleanup
trap 'cleanup' SIGINT

# Start the first VPN connection
start_vpn

# Wait for the OpenVPN process to establish the connection
wait $VPN_PID &

# Fetch and display the VPN-assigned IP address
fetch_vpn_ip

# Wait for the OpenVPN process
wait $VPN_PID

# After the VPN session ends, display the current IP address again
display_ip
