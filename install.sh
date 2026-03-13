#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}=== Dev Environment Setup ===${NC}"
echo

# --- Package Installation ---
if [[ "$OSTYPE" == darwin* ]]; then
  if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo -e "${YELLOW}Installing packages from Brewfile...${NC}"
  brew bundle --verbose --file="$REPO_DIR/Brewfile"
elif [[ -f /etc/arch-release ]]; then
  echo -e "${YELLOW}Installing with pacman...${NC}"
  sudo pacman -S --noconfirm bat dust duf fd lsd neovim ripgrep zoxide
elif [[ -f /etc/fedora-release ]]; then
  echo -e "${YELLOW}Installing with dnf...${NC}"
  sudo dnf install -y bat fd-find neovim ripgrep zoxide
elif [[ -f /etc/debian_version ]]; then
  echo -e "${YELLOW}Installing with apt...${NC}"
  sudo apt update && sudo apt install -y bat fd-find neovim ripgrep zoxide
  [[ ! -L /usr/local/bin/bat ]] && sudo ln -sf "$(which batcat)" /usr/local/bin/bat 2>/dev/null || true
  [[ ! -L /usr/local/bin/fd ]]  && sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
else
  echo -e "${RED}Unknown OS. Install tools manually.${NC}"
fi

# --- Copy configs ---
echo
echo -e "${YELLOW}Installing config files...${NC}"

# Backup existing configs (files, directories, or stale symlinks)
for target in "$HOME/.zshrc" "$HOME/.zsh"; do
  if [[ -e "$target" || -L "$target" ]]; then
    backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
    echo "  Backing up $target → $backup"
    mv "$target" "$backup"
  fi
done

cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
cp -R "$REPO_DIR/.zsh" "$HOME/.zsh"

# Git config (XDG standard — git reads ~/.config/git/config natively)
mkdir -p "$HOME/.config/git"
cp "$REPO_DIR/config/git/config" "$HOME/.config/git/config"

# Git user details (stored in ~/.gitconfig, separate from shared config)
if ! git config --file "$HOME/.gitconfig" user.name &>/dev/null; then
  echo
  echo -e "${YELLOW}Configure git identity:${NC}"
  read -rp "  Name:  " git_name
  read -rp "  Email: " git_email
  git config --file "$HOME/.gitconfig" user.name "$git_name"
  git config --file "$HOME/.gitconfig" user.email "$git_email"
fi

# iTerm2 dynamic profile
if [[ "$OSTYPE" == darwin* && -d "/Applications/iTerm.app" ]]; then
  echo -e "${YELLOW}Installing iTerm2 profile...${NC}"
  DYNAMIC_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$DYNAMIC_DIR"
  cp "$REPO_DIR/iterm2_profile.json" "$DYNAMIC_DIR/ZshModular.json"
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "zsh-modular-profile"
fi

# --- Runtime directories ---
mkdir -p "$HOME/.zsh/cache"
[[ ! -f "$HOME/.zsh/local.zsh" ]] && echo "# Local overrides — not tracked in git" > "$HOME/.zsh/local.zsh"

# --- Neovim (kickstart.nvim) ---
if [[ ! -d "$HOME/.config/nvim" ]]; then
  echo -e "${YELLOW}Installing kickstart.nvim...${NC}"
  git clone --depth=1 https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"
fi

# --- macOS defaults ---
if [[ "$OSTYPE" == darwin* && -f "$REPO_DIR/macos_defaults.sh" ]]; then
  echo
  bash "$REPO_DIR/macos_defaults.sh"
fi

echo
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo
echo -e "Run ${YELLOW}exec zsh${NC} to reload your shell."
echo -e "Run ${YELLOW}p10k configure${NC} to set up your prompt."
echo -e "Enable ${YELLOW}VS Code Settings Sync${NC} for editor preferences."
echo
echo -e "${YELLOW}=== Install from the Mac App Store ===${NC}"
echo "  Wins · 1Password · Plex · Plex Dash · Messenger · Telegram · WhatsApp"
echo
echo -e "Font: ${YELLOW}JetBrainsMono Nerd Font${NC} (terminal + VS Code)"
