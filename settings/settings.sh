#!/bin/bash

username=$(whoami)

# Clicking on files or folders selects them instead of opening them
sed -i '/KDE/a SingleClick=false' ~/.config/kdeglobals

# Add autostart items
sudo rm -rfv ~/.config/autostart/*
cp -a settings/autostart ~/.config/

# Remove guest account
sudo pacman -Rd systemd-guest-user

# Enable sunshine service
systemctl --machine="$username"@.host --user enable sunshine