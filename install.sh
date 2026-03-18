#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
[[ "$1" == "--force" || "$1" == "-f" ]] && FORCE=true

echo -e "${GREEN}=== Dev Environment Setup ===${NC}"
$FORCE && echo -e "${YELLOW}(force mode — reapplying all configs)${NC}"
echo

# --- Package Installation ---
if [[ "$OSTYPE" == darwin* ]]; then
  if ! command -v brew &>/dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for the rest of this script
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
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

# --- Symlink configs ---
echo
echo -e "${YELLOW}Installing config files...${NC}"

# Backup existing configs (real files/dirs, not our own symlinks)
for target in "$HOME/.zshrc" "$HOME/.zsh" "$HOME/.config/git/config"; do
  if [[ -e "$target" && ! -L "$target" ]]; then
    backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
    echo "  Backing up $target → $backup"
    mv "$target" "$backup"
  elif [[ -L "$target" ]]; then
    rm "$target"
  fi
done

ln -sf "$REPO_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/.zsh" "$HOME/.zsh"

# Git config (XDG standard — git reads ~/.config/git/config natively)
mkdir -p "$HOME/.config/git"
ln -sf "$REPO_DIR/config/git/config" "$HOME/.config/git/config"

# Git user details (stored in ~/.gitconfig, separate from shared config)
if $FORCE || ! git config --file "$HOME/.gitconfig" user.name &>/dev/null; then
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
  ln -sf "$REPO_DIR/iterm2_profile.json" "$DYNAMIC_DIR/ZshModular.json"
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "zsh-modular-profile"
fi

# --- Runtime directories ---
mkdir -p "$REPO_DIR/.zsh/cache"
[[ ! -f "$REPO_DIR/.zsh/local.zsh" ]] && echo "# Local overrides — not tracked in git" > "$REPO_DIR/.zsh/local.zsh"

# --- Neovim (kickstart.nvim) ---
if $FORCE || [[ ! -d "$HOME/.config/nvim" ]]; then
  echo -e "${YELLOW}Installing kickstart.nvim...${NC}"
  git clone --depth=1 https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"
fi

# --- Terminal.app font ---
if [[ "$OSTYPE" == darwin* ]]; then
  echo -e "${YELLOW}Setting Terminal.app font to JetBrainsMono Nerd Font...${NC}"
  osascript -e '
    tell application "Terminal"
      set font name of settings set "Basic" to "JetBrainsMonoNFM-Regular"
      set font size of settings set "Basic" to 14
    end tell'
fi

# --- VS Code terminal font ---
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
if [[ -f "$VSCODE_SETTINGS" ]]; then
  if $FORCE || ! grep -q 'terminal.integrated.fontFamily' "$VSCODE_SETTINGS"; then
    echo -e "${YELLOW}Setting VS Code terminal font...${NC}"
    # Insert font settings before the closing brace (gsed supports \n, macOS sed doesn't)
    gsed -i 's/}$/,\n    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono",\n    "terminal.integrated.fontSize": 14\n}/' "$VSCODE_SETTINGS"
  fi
elif [[ "$OSTYPE" == darwin* ]]; then
  echo -e "${YELLOW}Creating VS Code settings with terminal font...${NC}"
  mkdir -p "$(dirname "$VSCODE_SETTINGS")"
  cat > "$VSCODE_SETTINGS" << 'VSCEOF'
{
    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono",
    "terminal.integrated.fontSize": 14
}
VSCEOF
fi

# --- Claude Code statusline ---
if command -v npx &>/dev/null; then
  CLAUDE_SETTINGS="$HOME/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  if $FORCE || [[ ! -f "$CLAUDE_SETTINGS" ]]; then
    echo -e "${YELLOW}Configuring Claude Code statusline...${NC}"
    cat > "$CLAUDE_SETTINGS" << 'CLEOF'
{
  "statusLine": {
    "type": "command",
    "command": "npx -y @owloops/claude-powerline --theme=tokyo-night --style=powerline"
  }
}
CLEOF
  fi
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
echo "  Wins · 1Password · Perplexity · Plex · Plex Dash · Messenger · Telegram · WhatsApp"
echo
echo -e "Font: ${YELLOW}JetBrainsMono Nerd Font${NC} (terminal + VS Code)"
