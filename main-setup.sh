#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

username=$(whoami)

echo "Hello $username!"

read -r -p "Have you customized the setup to your needs? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # Mark chmod script as executable
    sudo chmod +x scripts/chmod.sh

    # Mark child scripts as executables
    ./scripts/chmod.sh

    # Applications installer
    ./apps/install-apps.sh

    # Application configs installer
    ./apps/install-app-configs.sh

    # Settings changer
    ./settings/settings.sh

    # Zsh installer
    ./apps/zsh/zsh-setup.sh

    # Photoshop installer
    ./apps/install-photoshop.sh

    # Rebooting sequence
    ./scripts/reboot.sh
else
  echo
  printf "You really should:
  - Edit main-setup.sh and comment out and script you do not want to run.
  - Edit settings/fstab or remove it entirely.$RED$BOLD A non-configured fstab file can break your system!$NC$NORMAL
  - Edit pacman and yay packages lists in apps/packages.
  - Edit install-apps.sh to remove installation of extra apps not present in pacman and yay.
  - Remove custom application entries you do not want in settings/applications.
  - Remove autostart entries you do not want in settings/autostart.
  - Remove services you do not want to run on startup in settings/services.
  - Edit settings/settings.sh and comment out the parts you do not want to setup.
  - Edit settings/user-overrides if you're using firefox."
fi
