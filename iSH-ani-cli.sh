#!/bin/sh
set -eu

# ani-cli setup script for VLC and optional download mode (-D)

log_info() { 
    printf "[INFO] %s\n" "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() { 
    printf "[ERROR] %s\n" "$(date '+%Y-%m-%d %H:%M:%S') $1" >&2
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
    log_info "Updating and installing required packages..."
    apk add --no-cache --update bash curl ffmpeg aria2 wget python3 py3-pip git fzf || log_error "Failed to install packages."
}

# Install or update ani-cli
install_ani_cli() {
    log_info "Checking ani-cli installation..."

    # Set installation directory
    ani_cli_dir="$HOME/.ani-cli"

    # Check if ani-cli is already installed
    if [ -d "$ani_cli_dir" ]; then
        log_info "ani-cli found in $ani_cli_dir, updating..."
        (cd "$ani_cli_dir" && git pull) || log_error "Failed to update ani-cli."
    else
        log_info "ani-cli not found, cloning repository..."
        git clone https://github.com/pystardust/ani-cli.git "$ani_cli_dir" || log_error "Failed to clone ani-cli."
    fi

    # Copy ani-cli binary to /usr/local/bin and set permissions
    cp "$ani_cli_dir/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to copy ani-cli to /usr/local/bin"
    chmod +x /usr/local/bin/ani-cli || log_error "Failed to set executable permission on /usr/local/bin/ani-cli"

    log_info "ani-cli is now installed and available as a command."
}

# Configure ani-cli alias based on user preference
configure_ani_cli() {
    log_info "Setting ani-cli alias..."

    shell_type=$(echo -e "Zsh\nBash" | fzf --prompt "Select your shell: " --height=5 --border --layout=reverse)
    if [ "$shell_type" = "Zsh" ]; then
        alias_command="echo \"alias ani='ani-cli'\" >> ~/.zshrc"
        log_info "Alias added to ~/.zshrc"
    else
        alias_command="echo \"alias ani='ani-cli'\" >> ~/.profile"
        log_info "Alias added to ~/.profile"
    fi

    # Append alias to appropriate shell configuration file
    if [ "$shell_type" = "Zsh" ]; then
        eval "$alias_command"
        source ~/.zshrc
    else
        eval "$alias_command"
        source ~/.profile
    fi
}

# Print final installation summary
print_final_message() {
    log_info "Installation complete."
    log_info "Run ani-cli with: ani"
    log_info "Select an episode and tap 'Tap to open VLC' to play your ani in VLC."
    log_info "Enjoy!"
}

main() {
    install_packages
    install_ani_cli
    configure_ani_cli
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
