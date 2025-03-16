#!/bin/sh
set -eu

ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"
ANSI_CLOSE="\e[0m"

ani_cli_dir="$HOME/.ani-cli"

log_info() { 
    printf "${ANSI_GREEN}[INFO]${ANSI_CLOSE} %s\n" "$1"
}

log_error() { 
    printf "${ANSI_RED}[ERROR]${ANSI_CLOSE} %s\n" "$(date '+%Y-%m-%d %H:%M:%S') $1" >&2
    exit 1
}

# fzf-based function for interactive Yes/No prompts
prompt_input() {
    local question="$1"
    local options="Yes\nNo"
    local result

    result=$(echo -e "$options" | fzf --prompt "$question: " --height=5 --border --layout=reverse)
    
    echo "$result"
}

# Install required system packages
install_packages() {
    log_info "Checking required packages..."

    # Check if required packages are already installed
    if command -v bash >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
        log_info "All required packages are already installed. Skipping installation."
        return
    fi

    log_info "We need to install required packages / dependencies..."
    install_choice=$(prompt_input "Should we install them?")

    if [ "$install_choice" = "No" ]; then
        log_info "Aborting..."
        exit 0
    fi

    log_info "Installing required packages..."
    apk add --no-cache bash curl git || log_error "Failed to install packages."
}

# Update ani-cli
update_ani_cli() {
    log_info "Updating ani-cli..."

    if [ -d "$ani_cli_dir" ]; then
        (cd "$ani_cli_dir" && git pull) || log_error "Failed to update ani-cli."

        # Ask the user if they want to create a backup
        backup_choice=$(prompt_input "Would you like to create a backup of the current ani-cli version?")

        if [ "$backup_choice" = "Yes" ]; then
            # Remove old backup if it exists
            if [ -f "/usr/local/bin/ani-cli.bak" ]; then
                log_info "Removing old backup..."
                rm -f /usr/local/bin/ani-cli.bak
            fi

            # Create a new backup with timestamp
            timestamp=$(date +"%Y%m%d-%H%M%S")
            log_info "Creating backup: ani-cli.bak.$timestamp..."
            cp /usr/local/bin/ani-cli "/usr/local/bin/ani-cli.bak.$timestamp"
        fi

        log_info "Copying ani-cli as 'ani-cli' and 'ani' to /usr/local/bin"
        cp "$ani_cli_dir/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to copy ani-cli to /usr/local/bin"
        cp "$ani_cli_dir/ani-cli" /usr/local/bin/ani || log_error "Failed to copy ani-cli as 'ani'"
        chmod +x /usr/local/bin/ani-cli || log_error "Failed to set executable permission on /usr/local/bin/ani-cli"
        chmod +x /usr/local/bin/ani || log_error "Failed to set executable permission on /usr/local/bin/ani"

        log_info "ani-cli has been updated successfully!"
        exit 0
    else
        log_error "ani-cli is not installed. Run the script to install it first."
    fi
}

# Install ani-cli
install_ani_cli() {
    log_info "Checking ani-cli installation..."

    if [ -d "$ani_cli_dir" ]; then
        log_info "ani-cli is already installed. Running update instead..."
        update_ani_cli
    fi

    log_info "ani-cli not found, cloning repository..."
    git clone https://github.com/pystardust/ani-cli.git "$ani_cli_dir" || log_error "Failed to clone ani-cli."

    log_info "Copying ani-cli as 'ani-cli' and 'ani' to /usr/local/bin"
    cp "$ani_cli_dir/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to copy ani-cli to /usr/local/bin"
    cp "$ani_cli_dir/ani-cli" /usr/local/bin/ani || log_error "Failed to copy ani-cli as 'ani'"
    chmod +x /usr/local/bin/ani-cli || log_error "Failed to set executable permission on /usr/local/bin/ani-cli"
    chmod +x /usr/local/bin/ani || log_error "Failed to set executable permission on /usr/local/bin/ani"

    log_info "ani-cli is now installed and available as 'ani' command."
}

# Print final installation summary
print_final_message() {
    log_info "Installation complete."
    log_info "Run ani-cli with: ani"
    log_info "Select an episode and tap 'Tap to open VLC' to play your ani in VLC."
    log_info "You need to have VLC installed to use ani. Open VLC once before using ani-cli to avoid playback issues."
    log_info "VLC can be downloaded from the App Store if you don't have it installed."
    log_info "Enjoy!"
}

main() {
    install_packages
    install_ani_cli
    print_final_message
}

## Main code starts here

# Ensure the script is executed as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root. Exiting..."
fi

# Check if fzf is installed
if ! command -v fzf >/dev/null 2>&1; then
    log_error "fzf is required but not installed. Run: apk add fzf"
fi

main
