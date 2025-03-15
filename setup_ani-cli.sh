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

# Ensure the script is executed as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root. Exiting..."
fi

# fzf-based function for interactive Yes/No prompts
prompt_input() {
    local question="$1"
    local options="Yes\nNo"
    local result

    # Display options in fzf and capture user selection
    result=$(echo -e "$options" | fzf --prompt "$question: " --height=5 --border --layout=reverse)
    
    echo "$result"
}

# Install required system packages
install_packages() {
    log_info "Updating and installing required packages..."
    apk add --no-cache --update bash curl ffmpeg aria2 wget python3 py3-pip git fzf || log_error "Failed to install packages."
}

# Install yt-dlp if not already installed
install_yt_dlp() {
    log_info "Checking for yt-dlp..."
    if ! command -v yt-dlp >/dev/null 2>&1; then
        log_info "yt-dlp not found, installing..."
        pip install --upgrade --break-system-packages yt-dlp || log_error "Failed to install yt-dlp."
    else
        log_info "yt-dlp is already installed."
    fi
}

# Install or update ani-cli
install_ani_cli() {
    log_info "Checking ani-cli installation..."

    # Check if ani-cli is already available in the system PATH
    ani_cli_path=$(command -v ani-cli || echo "")

    if [ -n "$ani_cli_path" ]; then
        log_info "ani-cli found at $ani_cli_path"

        # Determine if ani-cli was installed from a Git repository
        repo_path=$(cd "$(dirname "$ani_cli_path")" && git rev-parse --show-toplevel 2>/dev/null || echo "")

        if [ -n "$repo_path" ]; then
            log_info "Updating ani-cli from $repo_path..."
            (cd "$repo_path" && git pull) || log_error "Failed to update ani-cli."
            install -Dm755 "$repo_path/ani-cli/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to install ani-cli to /usr/local/bin"
        else
            log_info "ani-cli is installed, but not from a Git repository. Reinstalling..."
            rm -f /usr/local/bin/ani-cli
            git clone https://github.com/pystardust/ani-cli.git /tmp/ani-cli || log_error "Failed to clone ani-cli."
            install -Dm755 "/tmp/ani-cli/ani-cli/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to install ani-cli to /usr/local/bin"
            rm -rf /tmp/ani-cli
        fi
    else
        # ani-cli is not installed; proceed with fresh installation
        log_info "ani-cli not found, cloning repository..."
        git clone https://github.com/pystardust/ani-cli.git /tmp/ani-cli || log_error "Failed to clone ani-cli."
        install -Dm755 "/tmp/ani-cli/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to install ani-cli to /usr/local/bin"
        rm -rf /tmp/ani-cli
    fi
}

# Ensure the AnimeDownloads directory exists
create_directories() {
    log_info "Creating ~/AnimeDownloads..."
    mkdir -p "$HOME/AnimeDownloads" || log_error "Failed to create directory."
}

# Configure ani-cli alias based on user preference
configure_ani_cli() {
    log_info "Asking user if they want the Download (-D) option..."
    download_choice=$(prompt_input "Enable ani-cli download mode (-D)?")

    if [ "$download_choice" = "Yes" ]; then
        log_info "Download mode enabled."
        alias_command="alias ani='ani-cli -D'"
    else
        log_info "Download mode not enabled."
        alias_command="alias ani='ani-cli'"
    fi

    # Append alias to shell configuration files if not already set
    for shell_config in "$HOME/.profile" "$HOME/.bashrc"; do
        if [ -f "$shell_config" ] && ! grep -qxF "$alias_command" "$shell_config"; then
            echo "$alias_command" >> "$shell_config"
        fi
    done
}

# Reload shell configuration to apply changes immediately
reload_shell_config() {
    log_info "Reloading shell configuration..."
    [ -r "$HOME/.profile" ] && . "$HOME/.profile"
}

# Print final installation summary
print_final_message() {
    log_info "Installation complete."
    log_info "Run ani-cli with: ani"
    log_info "Select an episode and tap the 'vlc://' link to play in VLC."
    log_info "yt-dlp is installed and ready for downloading episodes (if enabled)."
    log_info "Enjoy!"
}

# Main execution flow
main() {
    install_packages
    install_yt_dlp
    install_ani_cli
    create_directories
    configure_ani_cli
    reload_shell_config
    print_final_message
}

main
