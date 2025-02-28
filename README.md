# System Information and File Collection Script

This Bash script collects system information and specific file types from a specified directory, compresses them into a ZIP file, splits the ZIP file into smaller chunks, and sends them to a Telegram chat. It also cleans up by deleting temporary files and clearing the command history.

## Features

- **System Information Collection**: Gathers hostname, username, operating system details, current directory, and environment variables.
- **File Collection**: Searches for specific file types (e.g., `.txt`, `.doc`, `.pdf`, `.jpg`, etc.) in a specified directory and its subdirectories.
- **File Compression**: Compresses the collected files and system information into a ZIP file.
- **File Splitting**: Splits the ZIP file into smaller chunks to stay under Telegram's 50 MB file size limit.
- **Telegram Integration**: Sends each chunk of the ZIP file to a specified Telegram chat using a bot.
- **Cleanup**: Deletes temporary files and clears the command history to remove footprints.

## Prerequisites

- **Bash**: The script is written in Bash and should be run in a Bash-compatible shell.
- **curl**: Required for sending messages and files to Telegram.
- **Telegram Bot**: You need a Telegram bot and its token to send messages and files.
- **Chat ID**: The chat ID of the Telegram chat where the files will be sent.

## Customizable Parameters

Before running the script, you need to customize the following parameters in the script:

- `TELEGRAM_BOT_TOKEN`: Replace with your Telegram bot token.
- `TELEGRAM_CHAT_ID`: Replace with your Telegram chat ID.
- `ROOT_DIRECTORY`: The root directory to start searching for files (default is `$HOME`).
- `HIDDEN_DIRECTORY`: The path where temporary files will be stored (default is `$HOME/.hidden_folder`).
- `MAX_FILE_SIZE`: The maximum size of each file chunk (default is 45 MB to stay under Telegram's 50 MB limit).
- `FILE_TYPES`: An array of file types to collect (e.g., `*.txt`, `*.doc`, `*.pdf`, etc.).

## Usage

1. **Clone the repository** or download the script to your local machine.
2. **Customize the parameters** in the script as described above.
3. **Make the script executable**:
   ```bash
   chmod +x script_name.sh
