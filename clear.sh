#!/bin/bash

# Script to clear all logs in Parrot Security OS and reset IP address

# Define log directory
log_dir="/var/log"

# List of log files to clear
log_files=(
    "auth.log"
    "syslog"
    "kern.log"
    "daemon.log"
    "messages"
    "dmesg"
    "dpkg.log"
    "apt/history.log"
    "apt/term.log"
    "journal/1"
    "wtmp"
    "btmp"
    "lastlog"
    "cron"
    "user.log"
    "mysql/*"
    "postgresql/*"
)

# Get the current logged-in username
current_user=$(whoami)

# Get the active network interface
interface=$(ip route | grep '^default' | awk '{print $5}')

# Confirmation prompt
read -p "Are you sure you want to clear all logs and reset the IP address? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Clear the system logs
echo "Clearing system logs..."
for log_file in "${log_files[@]}"; do
    log_path="$log_dir/$log_file"
    if [ -e "$log_path" ]; then
        echo "Clearing $log_path"
        if ! sudo truncate -s 0 "$log_path"; then
            echo "Failed to clear $log_path"
        fi
    else
        echo "$log_path does not exist."
    fi
done

# Clear journal logs (if systemd is used)
if command -v journalctl &> /dev/null; then
    echo "Clearing journal logs..."
    sudo journalctl --rotate
    sudo journalctl --vacuum-time=1s
fi

# Clean log files under /var/log/journal (if they exist)
if [ -d "/var/log/journal" ]; then
    echo "Cleaning /var/log/journal..."
    sudo rm -rf /var/log/journal/*
fi

# Clear the tmp folder (optional but useful for clearing temporary files)
echo "Clearing /tmp folder..."
sudo rm -rf /tmp/*

# Clear Bash history (optional)
echo "Clearing Bash history..."
history -c
sudo rm -rf /home/$current_user/.bash_history
sudo rm -rf /home/$current_user/.zsh_history

# Reset IP address
echo "Resetting IP address..."
# Flush current IP address
if [ -n "$interface" ]; then
    echo "Flushing IP address on interface $interface..."
    sudo ip addr flush dev "$interface"
else
    echo "No active network interface found."
fi

echo "Operation completed."
