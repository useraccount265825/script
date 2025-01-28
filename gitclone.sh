#!/bin/bash

# Script to clone multiple Git repositories

# Define the repository URLs
REPO1="https://github.com/LandGrey/pydictor.git"
REPO2="https://github.com/Sanix-Darker/Brute-Force-Login.git"
REPO3="https://github.com/threat9/routersploit.git"
REPO6="https://github.com/erforschr/bruteforce-http-auth.git"

# Function to clone a repository
clone_repo() {
    local repo_url=$1
    echo "Cloning repository: $repo_url"
    sudo git clone "$repo_url"

    # Check if the clone was successful
    if [ $? -eq 0 ]; then
        echo "Repository cloned successfully: $repo_url"
    else
        echo "Failed to clone the repository: $repo_url"
    fi
}

# Clone the repositories
clone_repo "$REPO1"
clone_repo "$REPO2"
clone_repo "$REPO3"
clone_repo "$REPO6"
