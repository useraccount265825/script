#!/bin/bash

# Get the current user's username
USER_NAME=$(whoami)

# Define the base URL and the download directory
BASE_URL="https://www.vpnbook.com"
URL="$BASE_URL/freevpn"
DOWNLOAD_DIR="/home/$USER_NAME/Downloads"  # Construct the Downloads path

# Create the download directory if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Change to the download directory
cd "$DOWNLOAD_DIR" || exit

# Download the webpage content
echo "Downloading webpage content..."
curl -s "$URL" -o page.html

# Extract all .zip file links from the specified class
echo "Extracting .zip file links..."
ZIP_LINKS=$(grep -oP 'href="\K[^"]*\.zip' page.html)

# Check if any links were found
if [ -z "$ZIP_LINKS" ]; then
    echo "No .zip links found. Please check the HTML structure."
    exit 1
fi

# Download each .zip file
for LINK in $ZIP_LINKS; do
    # Prepend the base URL to the link if it is a relative URL
    if [[ "$LINK" != http* ]]; then
        LINK="$BASE_URL$LINK"
    fi
    echo "Downloading $LINK..."
    wget "$LINK" || { echo "Failed to download $LINK"; exit 1; }
done

# Unzip all downloaded .zip files and extract only -udp53.ovpn files
for ZIP_FILE in *.zip; do
    if [[ -f "$ZIP_FILE" ]]; then
        echo "Unzipping $ZIP_FILE..."
        # List the contents of the zip file
        unzip -l "$ZIP_FILE"
        
        # Extract only the -udp53.ovpn files from the specific directory
        unzip -o "$ZIP_FILE" "*-udp53.ovpn" -d "$DOWNLOAD_DIR" || { echo "Failed to unzip $ZIP_FILE"; exit 1; }
    fi
done

# Copy the -udp53.ovpn files to the Downloads directory and remove the folders
echo "Copying -udp53.ovpn files to $DOWNLOAD_DIR and cleaning up..."
for dir in */; do
    if ls "$dir"*udp53.ovpn 1> /dev/null 2>&1; then
        cp "$dir"*udp53.ovpn "$DOWNLOAD_DIR"
        echo "Copied $dir*udp53.ovpn to $DOWNLOAD_DIR"
    else
        echo "No -udp53.ovpn file found in $dir"
    fi
done

# Remove all folders that were processed
echo "Removing all folders..."
rm -r */  # Removed 'sudo' to ensure it runs as the current user

# Clean up
echo "Cleaning up..."
rm page.html
rm *.zip

echo "Done! All -udp53.ovpn files have been extracted to $DOWNLOAD_DIR."
