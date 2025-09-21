#!/bin/bash

# A script to add the local machine's SSH key to a remote server.
# It checks for existing keys and prompts to create new ones if needed.

# --- Color Definitions ---
C_GREEN='\033[0;32m'
C_RED='\033[0;31m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_GRAY='\033[0;37m'
C_NC='\033[0m' # No Color

# --- Functions ---
# Function to print a formatted header
function print_header {
    clear
    echo -e "${C_GRAY}========================================"
    echo -e "  ${C_NC}SSH Public Key Adder for Linux/macOS"
    echo -e "${C_GRAY}========================================${C_NC}\n"
}

# --- Main Script ---
print_header

KEY_PATH="$HOME/.ssh/id_rsa.pub"
CREATE_NEW="n"

# 1. Check if an SSH key already exists
if [ -f "$KEY_PATH" ]; then
    echo -e "${C_GREEN}An existing SSH public key was found:${C_NC}"
    echo -e "${C_GRAY}-----------------------------------------------------"
    cat "$KEY_PATH"
    echo -e "-----------------------------------------------------${C_NC}\n"
    read -p "Do you want to create a new key pair? (This will overwrite the existing one) [y/N]: " CREATE_NEW
else
    echo -e "${C_RED}No existing SSH key pair found.${C_NC}"
    CREATE_NEW="y" # Force creation if no key exists
fi

# 2. Generate a new key pair if the user wants to
if [[ "$CREATE_NEW" == "y" || "$CREATE_NEW" == "Y" ]]; then
    echo -e "\n${C_CYAN}Generating a new SSH key pair...${C_NC}"
    # Ensure the .ssh directory exists
    mkdir -p "$HOME/.ssh"
    # Prompts for file location and passphrase will appear here
    ssh-keygen -t rsa -b 4096
    
    # Check if the key was actually created
    if [ ! -f "$KEY_PATH" ]; then
        echo -e "\n${C_RED}(!) SSH key generation failed or was cancelled. Exiting.${C_NC}"
        exit 1
    fi
    echo -e "\n${C_GREEN}New SSH key pair generated successfully.${C_NC}"
fi

echo -e "\nThe script will now copy the public key to your remote machine."

# 3. Get remote machine details
while true; do
    read -p "Enter the username for the remote machine: " remoteUser
    if [ -n "$remoteUser" ]; then
        break
    else
        echo -e "${C_RED}(!) Remote username cannot be empty. Please try again.${C_NC}"
    fi
done

while true; do
    read -p "Enter the remote machine's IP address or hostname: " remoteHost
    if [ -n "$remoteHost" ]; then
        break
    else
        echo -e "${C_RED}(!) Remote host cannot be empty. Please try again.${C_NC}"
    fi
done

remoteAddress="$remoteUser@$remoteHost"

# 4. Copy the key using ssh-copy-id
echo -e "\n${C_CYAN}Attempting to copy the key to $remoteAddress...${C_NC}"
echo "You will be prompted for the remote user's password."

ssh-copy-id "$remoteAddress"

# 5. Check the result
if [ $? -eq 0 ]; then
    echo -e "\n${C_GREEN}Success! Your SSH key has been added to the remote machine.${C_NC}"
    echo "You should now be able to SSH into $remoteAddress without a password."
else
    echo -e "\n${C_RED}(!) An error occurred. The key could not be copied.${C_NC}"
    echo -e "${C_RED}Please check the following:"
    echo -e "${C_RED}  - The remote address and username are correct."
    echo -e "${C_RED}  - You entered the correct password for the remote user."
    echo -e "${C_RED}  - The remote server has SSH enabled."
    echo -e "${C_RED}  - The 'ssh-copy-id' command is available on your system.${C_NC}"
fi

