<# :
@echo off
setlocal
echo Running the SSH Key Adder...

:: Define a path for the temporary PowerShell script
set "TEMP_PS1=%TEMP%\~tmp_ssh_adder_%RANDOM%.ps1"

:: Extract the PowerShell part of this script (everything after line 23) and save it to the temp file
more +23 "%~f0" > "%TEMP_PS1%"

:: Execute the temporary PowerShell script in a proper interactive session
powershell -ExecutionPolicy Bypass -NoProfile -File "%TEMP_PS1%"

:: Clean up the temporary file
if exist "%TEMP_PS1%" del "%TEMP_PS1%"

echo.
echo Script finished. Press any key to close this window.
pause >nul
endlocal
exit /b
#>

# --- PowerShell Script Starts Here ---

<#
.SYNOPSIS
    A PowerShell script to add the local machine's SSH key to a remote server.
    It checks for existing keys and prompts to create new ones if needed.
#>

# --- Functions ---
# Function to print a formatted header
function Print-Header {
    # Set console colors based on your preference
    $host.ui.rawui.backgroundcolor = "Black"
    $host.ui.rawui.foregroundcolor = "White"
    Clear-Host
    Write-Host "========================================" -ForegroundColor DarkGray
    Write-Host "  SSH Public Key Adder for Windows" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor DarkGray
    Write-Host
}

# --- Main Script ---
Print-Header

$keyPath = "$env:USERPROFILE\.ssh\*.pub"

# 1. Check if an SSH key already exists
if (Test-Path -Path $keyPath) {
    Write-Host "An existing SSH public key was found:" -ForegroundColor Green
    Write-Host "-----------------------------------------------------" -ForegroundColor Gray
    Get-Content $keyPath | Write-Host
    Write-Host "-----------------------------------------------------" -ForegroundColor Gray
    Write-Host
    $createNew = Read-Host "Do you want to create a new key pair? (This will overwrite the existing one) [y/N]"
}
else {
    Write-Host "No existing SSH key pair found." -ForegroundColor Red
    $createNew = "y" # Force creation if no key exists
}

# 2. Generate a new key pair if the user wants to
if ($createNew -eq 'y' -or $createNew -eq 'Y') {
    Write-Host
    Write-Host "Generating a new SSH key pair..." -ForegroundColor Cyan
    # Ensure the .ssh directory exists
    if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
        New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory -Force | Out-Null
    }
    # Prompts for file location and passphrase will appear here
    ssh-keygen.exe -t rsa -b 4096
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "(!) SSH key generation failed. Exiting." -ForegroundColor Red
        exit 1
    }
    Write-Host "New SSH key pair generated successfully." -ForegroundColor Green
}

# Ensure the public key file exists before proceeding
if (-not (Test-Path $keyPath)) {
    Write-Host "(!) Public key file not found at $keyPath. Please run the script again." -ForegroundColor Red
    exit 1
}

Write-Host
Write-Host "The script will now copy the public key to your remote machine."

# 3. Get remote machine details
do {
    $remoteUser = Read-Host "Enter the username for the remote machine"
    if ([string]::IsNullOrWhiteSpace($remoteUser)) {
        Write-Host "(!) Remote username cannot be empty. Please try again." -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($remoteUser))

do {
    $remoteHost = Read-Host "Enter the remote machine's IP address or hostname"
    if ([string]::IsNullOrWhiteSpace($remoteHost)) {
        Write-Host "(!) Remote host cannot be empty. Please try again." -ForegroundColor Red
    }
} while ([string]::IsNullOrWhiteSpace($remoteHost))

$remoteAddress = "$($remoteUser)@$($remoteHost)"


# 4. Copy the key
Write-Host
Write-Host "Attempting to copy the key to $remoteAddress..." -ForegroundColor Cyan
Write-Host "You will be prompted for the remote user's password."

# This is the most reliable method in PowerShell. It gets the key content
# and pipes it directly to the standard input of the remote 'cat' command.
$remoteCommand = "mkdir -p ~/.ssh; chmod 700 ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys"

# Execute the command and check the result directly.
Get-Content -Path $keyPath -Raw | ssh $remoteAddress $remoteCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host
    Write-Host "Success! Your SSH key has been added to the remote machine." -ForegroundColor Green
    Write-Host "You should now be able to SSH into $remoteAddress without a password."
}
else {
    # If the command fails, print the troubleshooting steps.
    Write-Host
    Write-Host '(!) An error occurred. The key could not be copied.' -ForegroundColor Red
    Write-Host 'Please check the following:' -ForegroundColor Red
    Write-Host '  - The remote address and username are correct.' -ForegroundColor Red
    Write-Host '  - You entered the correct password for the remote user.' -ForegroundColor Red
    Write-Host '  - The remote server has SSH enabled and allows public key authentication.' -ForegroundColor Red
    Write-Host '  - The OpenSSH Client is installed on your Windows machine.' -ForegroundColor Red
}



