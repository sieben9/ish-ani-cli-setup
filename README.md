# iSH ani-cli Setup

This repository provides a setup script to install and configure ani-cli for streaming anime via VLC on iSH.

## Features
- Installs ani-cli and required dependencies
- Configures ani-cli for VLC streaming only
- Creates a default download directory (~/AnimeDownloads)
- Provides a simple alias (ani) for quick access

## Installation

> **Note:** This script requires root privileges. If you encounter permission errors, run the script as root (e.g., `sudo ./setup_ani-cli.sh`).

1. Open iSH on your iPhone.
2. Clone this repository:
   ```sh
   git clone https://github.com/sieben9/ish-ani-cli-setup.git
   # OR use SSH:
   git clone git@github.com:sieben9/ish-ani-cli-setup.git
   ```
3. Run the script:
   ```sh
   ./setup_ani-cli.sh
   ```

## Usage

`ani-cli` is a lightweight command-line tool that allows you to stream anime directly from various sources. It fetches episode links and plays them via VLC. This setup makes it possible to watch anime within iSH on iPhone.

### Shell Compatibility
- The `ani` alias is automatically set for `ash` (default shell in iSH).
- If using `zsh`, manually add the alias to `~/.zshrc`:
  ```sh
  echo "alias ani='ani-cli'" >> ~/.zshrc
  source ~/.zshrc
  ```

Once installed, you can start ani-cli with:
  ```sh
  ani
  ```
  This will launch ani-cli for streaming via VLC.
- Search for an anime and select an episode.
- Tap the `vlc://` link in iSH to open VLC and start streaming.

## Using VLC with ani-cli
1. Search for an anime:
   ```sh
   ani "One Piece"
   ```
2. Select an episode.
3. Tap the `vlc://` link in iSH.
4. VLC will open and start streaming.

## Troubleshooting
### ani: command not found
- Run:
  ```sh
  source ~/.profile
  ```
  
If `ani` is still not recognized, restart iSH or run:
```sh
exec sh
```

- If using `zsh`, manually add the alias:
  ```sh
  echo "alias ani='ani-cli'" >> ~/.zshrc
  source ~/.zshrc
  ```

## Requirements
- **iSH Shell** (Download from the App Store)  
  - Required to run the setup script and ani-cli.
- **VLC for Mobile** (Download from the App Store)  
  - Needed for streaming anime directly on iPhone.

## License
This project is released under the MIT License.
