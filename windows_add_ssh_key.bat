<#
.SYNOPSIS
  A self-contained PowerShell script embedded in a batch file to add an SSH key to a remote host.
.DESCRIPTION
  This script checks for an existing SSH key, generates one if needed, and copies the public key to a remote server.
#>

@echo off
REM --- Batch portion to execute the embedded PowerShell script ---
cls
echo Running the SSH Key Adder...

REM --- Create a temporary file for the PowerShell script ---
set "TEMP_PS1=%TEMP%\~tmp_ssh_adder_%RANDOM%.ps1"

REM --- Extract the PowerShell code from this batch file and save it to the temp file ---
(
    more +24 "%~f0"
) > "%TEMP_PS1%"

REM --- Execute the PowerShell script and then clean up ---
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP_PS1%"
del "%TEMP_PS1%"

echo.
echo Script finished. Press any key to close this window.
pause > nul
exit /b

<# --- Start of embedded PowerShell Script --- #>

function Show-AsciiArt {
    $art = @"
    ._________________.
    | _______________ |
    | |XXXXXXXXXXXXX| |
    | |_____________| |
    |_________________|
      V V V V V V V
"@
    Write-Host -ForegroundColor Cyan $art
}

function Add-SshKey {
    Show-AsciiArt
    Write-Host "`nSSH Public Key Adder for Windows`n" -ForegroundColor Green

    $sshPath = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh"
    $privateKeyPath = Join-Path -Path $sshPath -ChildPath "id_rsa"
    $publicKeyPath = Join-Path -Path $sshPath -ChildPath "id_rsa.pub"
    $publicKey = ""

    # Check for existing SSH key
    if (Test-Path $publicKeyPath) {
        Write-Host "An existing SSH public key was found:`n" -ForegroundColor Yellow
        $publicKey = Get-Content $publicKeyPath
        Write-Host $publicKey
        $response = Read-Host "`nDo you want to create a new key pair? (This will overwrite the existing one) [y/N]"
        if ($response -eq 'y') {
            # Generate a new key pair
            ssh-keygen -t rsa -b 4096 -f $privateKeyPath -N "" -q
            $publicKey = Get-Content $publicKeyPath
            Write-Host "`nNew key pair generated." -ForegroundColor Green
        }
    }
    else {
        Write-Host "No SSH key found. Generating a new key pair..." -ForegroundColor Yellow
        if (-not (Test-Path $sshPath)) {
            New-Item -Path $sshPath -ItemType Directory | Out-Null
        }
        ssh-keygen -t rsa -b 4096 -f $privateKeyPath -N "" -q
        $publicKey = Get-Content $publicKeyPath
        Write-Host "`nNew key pair generated." -ForegroundColor Green
    }

    Write-Host "`nThe script will now copy the public key to your remote machine."

    # Get remote machine details
    $username = Read-Host "Enter the username for the remote machine"
    while ([string]::IsNullOrWhiteSpace($username)) {
        Write-Host "Username cannot be empty. Please try again." -ForegroundColor Red
        $username = Read-Host "Enter the username for the remote machine"
    }

    $remoteHost = Read-Host "Enter the remote machine's IP address or hostname"
    while ([string]::IsNullOrWhiteSpace($remoteHost)) {
        Write-Host "Remote host cannot be empty. Please try again." -ForegroundColor Red
        $remoteHost = Read-Host "Enter the remote machine's IP address or hostname"
    }

    $remoteAddress = "$username@$remoteHost"

    # Copy the key to the remote machine
    Write-Host "`nAttempting to copy the key to $remoteAddress..." -ForegroundColor Cyan
    Write-Host "You will be prompted for the remote user's password."

    $remoteCommand = "mkdir -p '$env:USERPROFILE\.ssh'; chmod 700 '$env:USERPROFILE\.ssh'; echo `"$publicKey`" >> '$env:USERPROFILE\.ssh\authorized_keys'; chmod 600 '$env:USERPROFILE\.ssh\authorized_keys'"
    
    try {
        ssh $remoteAddress $remoteCommand
        Write-Host "`n`n✅ Success! The key was copied." -ForegroundColor Green
        Write-Host "You should now be able to SSH into '$remoteAddress' without a password."
    }
    catch {
        Write-Host "`n❌ An error occurred. The key could not be copied." -ForegroundColor Red
        Write-Host "Please check the following:"
        Write-Host " - The remote address and username are correct."
        Write-Host " - You entered the correct password for the remote user."
        Write-Host " - The remote server has SSH enabled and allows public key authentication."
        Write-Host " - The OpenSSH Client is installed on your Windows machine."
    }
}

Add-SshKey

