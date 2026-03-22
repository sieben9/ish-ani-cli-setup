# iSH ani-cli Setup

This repository provides a setup script to install and configure [ani-cli](https://github.com/pystardust/ani-cli) for streaming anime via VLC on iSH.

## Features
- Installs ani-cli and required dependencies
- Automatically updates ani-cli if already installed
- Copies ani-cli as `ani` for quick access
- Asks the user whether to create a backup of the previous version before updating

## Installation

> **Note:** This script must be run as `root`. Alpine Linux (used in iSH) defaults to the `root` user, so `sudo` is not needed.

1. Open iSH on your iPhone.
2. Clone this repository:
   ```sh
   git clone https://github.com/sieben9/ish-ani-cli-setup.git
   # OR use SSH:
   git clone git@github.com:sieben9/ish-ani-cli-setup.git
   ```
3. Run the setup script:
   ```sh
   ./setup_ani-cli.sh
   ```

## Usage

Once installed, you can start ani-cli with:
```sh
ani
```
This will launch ani-cli for streaming via VLC.

### How it works:
1. Run `ani` to start the interactive search.
2. Select an anime from the list.
3. Choose an episode.
4. Tap the `vlc://` link in iSH.
5. VLC will open and start streaming.

## Backup Feature
- Before updating, the script asks if you want to **create a backup of the previous ani-cli version**.
- Backups are stored as `/usr/local/bin/ani-cli.bak.YYYYMMDD-HHMMSS`.
- If an update fails, you can manually restore the last working version.

## Troubleshooting
### ani: command not found
If `ani` is not recognized, restart iSH or run:
```sh
exec ash
```

### VLC does not open
- Ensure VLC is installed from the App Store.
- You **must open VLC at least once before using ani-cli** to avoid playback issues.

## Requirements
- **[iSH Shell](https://apps.apple.com/us/app/ish-shell/id1436902243)** (Download from the App Store)  
  - Required to run the setup script and ani-cli.
- **[VLC for Mobile](https://apps.apple.com/us/app/vlc-for-mobile/id650377962)** (Download from the App Store)  
  - Needed for streaming anime directly on iPhone.
- **fzf** (Installed via `apk add fzf`)  
  - Required for interactive prompts in the script.

## License
This project is released under the MIT License.
