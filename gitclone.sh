#!/bin/bash

# Script to clone a Git repository

REPO_URL="https://github.com/Sanix-Darker/Brute-Force-Login.git"

# Attempt to clone the repository
sudo git clone $REPO_URL

# Check if the clone was successful
if [ $? -eq 0 ]; then
    echo "Repository cloned successfully."
else
    echo "Failed to clone the repository. Please check the URL."
fi
