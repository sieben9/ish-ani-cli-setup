#!/bin/sh

# ish ani-cli setup for vlc 

log_info() { echo "[INFO] $1"; }
log_error() { echo "[ERROR] $1" >&2; }

# Install required packages
install_packages() {
    log_info "Updating package list..."
    apk update || { log_error "Failed to update package list."; exit 1; }

    log_info "Installing required packages..."
    apk add --no-cache bash curl ffmpeg aria2 wget yt-dlp git || { log_error "Failed to install packages."; exit 1; }
}

# Install ani-cli
install_ani_cli() {
    log_info "Checking ani-cli installation..."
    if [ ! -d "$HOME/ani-cli" ]; then
        log_info "Cloning ani-cli repository..."
        git clone https://github.com/pystardust/ani-cli.git "$HOME/ani-cli" || { log_error "Failed to clone ani-cli."; exit 1; }
    else
        log_info "Updating ani-cli..."
        cd "$HOME/ani-cli" && git pull || { log_error "Failed to update ani-cli."; exit 1; }
    fi

    log_info "Installing ani-cli..."
    install -Dm755 "$HOME/ani-cli/ani-cli" /usr/local/bin/ani-cli || { log_error "Failed to install ani-cli."; exit 1; }
}

# Create necessary directories
create_directories() {
    log_info "Creating ~/AnimeDownloads..."
    mkdir -p "$HOME/AnimeDownloads" || { log_error "Failed to create directory."; exit 1; }
}

# Configure ani-cli alias
configure_ani_cli() {
    log_info "Setting ani-cli alias..."
    grep -qxF "alias ani='ani-cli -s gogo'" "$HOME/.profile" || echo "alias ani='ani-cli -s gogo'" >> "$HOME/.profile"
}

# Reload shell configuration
reload_shell_config() {
    log_info "Reloading shell configuration..."
    . "$HOME/.profile"
}

# Final message
print_final_message() {
    log_info "Installation complete."
    log_info "Run ani-cli with: ani"
    log_info "Select an episode and tap the 'vlc://' link to play in VLC."
    log_info "enjoy!"
}

log_info "--- ish set up for ani-cli ---"

main() {
    install_packages
    install_ani_cli
    create_directories
    configure_ani_cli
    reload_shell_config
    print_final_message
}

main
