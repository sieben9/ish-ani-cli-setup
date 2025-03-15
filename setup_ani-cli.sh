#!/bin/sh

# ish ani-cli setup for vlc 

log_info() { echo "[INFO] $1"; }
log_error() { 
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2 
    exit 1
}

# Install required packages
install_packages() {
    log_info "Updating package list..."
    apk update || log_error "Failed to update package list."

    log_info "Installing required packages..."
apk add --no-cache bash curl ffmpeg aria2 wget python3 py3-pip git || log_error "Failed to install packages."
}

# Install yt-dlp
install_yt_dlp() {
    log_info "Checking for yt-dlp..."
    if ! command -v yt-dlp >/dev/null 2>&1; then
        log_info "yt-dlp not found, installing..."
        pip install --upgrade yt-dlp || log_error "Failed to install yt-dlp."

        # Ensure yt-dlp is accessible globally
        ln -sf "$HOME/.local/bin/yt-dlp" /usr/local/bin/yt-dlp
    else
        log_info "yt-dlp is already installed."
    fi
}

# Install ani-cli
install_ani_cli() {
    log_info "Checking ani-cli installation..."
    if [ ! -d "$HOME/ani-cli" ]; then
        log_info "Cloning ani-cli repository..."
        git clone https://github.com/pystardust/ani-cli.git "$HOME/ani-cli" || log_error "Failed to clone ani-cli."
    else
        log_info "Updating ani-cli..."
        cd "$HOME/ani-cli" && git pull || log_error "Failed to update ani-cli."
    fi

    log_info "Installing ani-cli..."
    install -Dm755 "$HOME/ani-cli/ani-cli" /usr/local/bin/ani-cli || log_error "Failed to install ani-cli."
}

# Create necessary directories
create_directories() {
    log_info "Creating ~/AnimeDownloads..."
    mkdir -p "$HOME/AnimeDownloads" || log_error "Failed to create directory."
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
    log_info "yt-dlp is installed and ready for downloading episodes."
    log_info "Enjoy!"
}

log_info "--- iSH set up for ani-cli ---"
log_info "Installation complete. Enjoy using ani-cli!"

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