# iSH ani-cli Setup

This repository provides a setup script to install and configure ani-cli on iSH (Alpine Linux shell for iOS) with VLC for Mobile integration. It ensures all required dependencies are installed and configures ani-cli to stream anime directly to VLC.

## Features
- Installs ani-cli and necessary dependencies
- Sets up streaming via VLC for Mobile (`vlc://` URL scheme)
- Creates a default download directory (`~/AnimeDownloads`)
- Provides a simple alias (`ani`) for quick access

## Installation

1. Open iSH on your iPhone.
2. Clone this repository:
   ```sh
   git clone git@github.com:sieben9/ish-ani-cli-setup.git
   cd ish-ani-cli-setup
   ```
3. Make the setup script executable:
   ```sh
   chmod +x setup_ani-cli.sh
   ```
4. Run the script:
   ```sh
   ./setup_ani-cli.sh
   ```

## Usage

- Start ani-cli:
  ```sh
  ani
  ```
- Search for an anime and select an episode.
- Tap the `vlc://` link in iSH to open VLC and start streaming.

## Requirements
- **iSH Shell** (Download from the App Store)
- **VLC for Mobile** (Download from the App Store)

## License
This project is released under the MIT License.
