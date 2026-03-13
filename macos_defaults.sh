#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== macOS Defaults ===${NC}"
echo

# --- Keyboard ---
echo -e "${YELLOW}Setting faster key repeat...${NC}"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for accented characters (enables key repeat everywhere)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -false

# --- Finder ---
echo -e "${YELLOW}Configuring Finder...${NC}"
# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar at bottom of Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search current folder by default (not entire Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# --- Dock ---
echo -e "${YELLOW}Configuring Dock...${NC}"
# Clear all default apps and set curated dock
defaults write com.apple.dock persistent-apps -array \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Visual Studio Code.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Obsidian.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Library/CoreServices/Finder.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# Add Downloads stack (fan view, sorted by date added)
defaults write com.apple.dock persistent-others -array \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://$HOME/Downloads/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>1</integer><key>arrangement</key><integer>2</integer></dict><key>tile-type</key><string>directory-tile</string></dict>" \
  "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://$HOME/.Trash/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>displayas</key><integer>1</integer><key>showas</key><integer>1</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"

# Don't show recent apps in dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows into their application icon
defaults write com.apple.dock minimize-to-application -bool true

# --- Screenshots (CleanShot handles these, but set sane defaults as fallback) ---
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# --- Trackpad & Input ---
echo -e "${YELLOW}Configuring trackpad and input...${NC}"
# Disable natural scrolling (scroll direction matches finger movement)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# --- Misc ---
echo -e "${YELLOW}Configuring misc settings...${NC}"
# Disable DS_Store on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Restart affected apps
echo -e "${YELLOW}Restarting Finder and Dock...${NC}"
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo
echo -e "${GREEN}=== macOS Defaults Applied ===${NC}"
echo -e "Some changes require a logout/restart to take effect."
