# SSH Key Adder Scripts

This repository contains scripts to simplify adding a local machine's SSH public key to a remote server for passwordless authentication.

* `add-ssh-key.sh`: For Linux and macOS.
* `add-ssh-key.bat`: A self-contained Batch/PowerShell hybrid script for Windows.
* `add-ssh-key.ps1`: A pure PowerShell script, ideal for remote execution from GitHub.

## Features

* **✨ Cross-Platform:** Scripts provided for both Windows and Unix-like systems (Linux, macOS).
* **🗣️ User-Friendly:** A clean, interactive interface guides you through the entire process.
* **🔍 Key Detection:** Automatically checks if an SSH key pair already exists on your machine.
* **🔑 Key Generation:** Offers to create a new key pair if one doesn't exist.
* **🌐 Flexible:** Prompts for the remote username and hostname separately.

## Usage

### For Windows

Download the `add-ssh-key.bat` file and double-click it to run. It will open a console window and guide you through the process.

### For Linux & macOS

1.  Make the script executable:
    ```sh
    chmod +x add-ssh-key.sh
    ```
2.  Run the script from your terminal:
    ```sh
    ./add-ssh-key.sh
    ```

---

## One-Liner Execution from GitHub

Run the scripts directly from GitHub without downloading any files.

### Windows (Recommended)

This command runs the pure PowerShell (`.ps1`) script.

#### Step 1: Get the Raw URL

1.  Navigate to the `add-ssh-key.ps1` file in your GitHub repository.
2.  Click the **"Raw"** button in the top-right corner of the file view.
3.  Copy the URL from your browser's address bar. It should start with `https://raw.githubusercontent.com/...`

#### Step 2: Run the Command

Open a **PowerShell** terminal and run the command below.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression (Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/m1293b/ssh_key_insert_scripts/refs/heads/main/windows_remote_add_ssh_key.ps1')"
```

### Linux & macOS

This command runs the `add-ssh-key.sh` script.

#### Step 1: Get the Raw URL

1.  Navigate to the `add-ssh-key.sh` file in your GitHub repository.
2.  Click the **"Raw"** button.
3.  Copy the URL from your browser's address bar.

#### Step 2: Run the Command

Open your terminal and run the command below.

```sh
bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/m1293b/ssh_key_insert_scripts/refs/heads/main/linux_add_ssh_key.sh')"
```
    
