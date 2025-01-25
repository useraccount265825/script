#!/bin/bash

# Base URL for fetching the .ovpn files
BASE_URL="https://www.freeopenvpn.org"

# Array of URLs to fetch .ovpn files from
URLS=(
    "$BASE_URL/private.php?cntid=USA&lang=en"
    "$BASE_URL/private.php?cntid=Russia&lang=en"
    "$BASE_URL/private.php?cntid=Japan&lang=en"
    "$BASE_URL/private.php?cntid=Korea&lang=en"
    "$BASE_URL/private.php?cntid=Thailand&lang=en"
)

# Create a directory to store the downloaded .ovpn files
DOWNLOAD_DIR="$HOME/Downloads/"
mkdir -p "$DOWNLOAD_DIR"

# Loop through each URL
for URL in "${URLS[@]}"; do
    echo "Fetching .ovpn files from $URL..."

    # Temporary file to store the HTML content
    TEMP_HTML=$(mktemp)

    # Fetch the HTML content
    curl -s "$URL" -o "$TEMP_HTML"

    # Extract the .ovpn file links from the class "data"
    OVPN_LINKS=$(grep -oP 'class="data".*?href="\K[^"]*\.ovpn' "$TEMP_HTML")

    # Check if any .ovpn links were found
    if [ -z "$OVPN_LINKS" ]; then
        echo "No .ovpn files found at $URL."
        rm "$TEMP_HTML"
        continue
    fi

    # Download each .ovpn file that contains "_udp"
    for LINK in $OVPN_LINKS; do
        # Check if the link contains "_udp"
        if [[ "$LINK" == *_udp.ovpn ]]; then
            # Construct the full URL
            FULL_URL="$BASE_URL$LINK"
            FILENAME=$(basename "$LINK")
            echo "Downloading $FILENAME from $FULL_URL..."
            curl -o "$DOWNLOAD_DIR/$FILENAME" "$FULL_URL"
        fi
    done

    # Clean up
    rm "$TEMP_HTML"
done

echo "Download completed. Files saved to $DOWNLOAD_DIR."
