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

    if ! command -v fzf >/dev/null 2>&1; then
        log_info "fzf not found, using default option (No)."
        echo "No"
        return
    fi

    result=$(echo -e "$options" | fzf --prompt "$question: " --height=5 --border --layout=reverse)
    
    echo "$result"
}

# Install required system packages
install_packages() {
    log_info "Updating and installing required packages..."
    apk add --no-cache --update bash curl ffmpeg aria2 wget python3 py3-pip git fzf || log_error "Failed to install packages."
}

# Check if fzf is installed
if ! command -v fzf >/dev/null 2>&1; then
    log_error "fzf is missing! Package installation may have failed."
fi

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
            [ -d /tmp/ani-cli ] && rm -rf /tmp/ani-cli
            git clone https://github.com/pystardust/ani-cli.git /tmp/ani-cli || log_error "Failed to clone ani-cli."
            cp /tmp/ani-cli/ani-cli /usr/local/bin/ani-cli && chmod +x /usr/local/bin/ani-cli || log_error "Failed to install ani-cli to /usr/local/bin"
            rm -rf /tmp/ani-cli
        fi
    else
        # ani-cli is not installed; proceed with fresh installation
        log_info "ani-cli not found, cloning repository..."
        [ -d /tmp/ani-cli ] && rm -rf /tmp/ani-cli
        git clone https://github.com/pystardust/ani-cli.git /tmp/ani-cli || log_error "Failed to clone ani-cli."
        cp /tmp/ani-cli/ani-cli /usr/local/bin/ani-cli && chmod +x /usr/local/bin/ani-cli || log_error "Failed to install ani-cli to /usr/local/bin"
        rm -rf /tmp/ani-cli
    fi
}

# Configure ani-cli alias based on user preference
configure_ani_cli() {
    log_info "Setting ani-cli alias..."

    shell_type=$(prompt_input "Are you using Zsh? (Yes/No)")
    if [ "$shell_type" = "Yes" ]; then
        alias_command="echo \"alias ani='ani-cli'\" >> ~/.zshrc"
        log_info "Alias added to ~/.zshrc"
    else
        alias_command="echo \"alias ani='ani-cli'\" >> ~/.profile"
        log_info "Alias added to ~/.profile"
    fi

    # Append alias to appropriate shell configuration file
    if [ "$shell_type" = "Yes" ]; then
        eval "$alias_command"
        source ~/.zshrc
    else
        eval "$alias_command"
        source ~/.profile
    fi
}

# Reload shell configuration to apply changes immediately
reload_shell_config() {
    log_info "Reloading shell configuration..."
    log_info "If you are using a shell other than ash, manually source your shell config file (e.g., ~/.zshrc, ~/.bashrc)."
    [ -r "$HOME/.profile" ] && . "$HOME/.profile"
}

# Print final installation summary
print_final_message() {
    log_info "Installation complete."
    log_info "Run ani-cli with: ani"
    log_info "Select an episode and tap the 'vlc://' link to play in VLC."
    log_info "Enjoy!"
}

# Main execution flow
main() {
    install_packages
    install_ani_cli
    configure_ani_cli
    reload_shell_config
    print_final_message
}

main
