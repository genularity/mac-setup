#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
SKIP_BACKUP=false
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=true ;;
    --skip-backup) SKIP_BACKUP=true ;;
  esac
done

echo -e "${GREEN}=== Dev Environment Setup ===${NC}"
if $FORCE; then
  echo -e "${YELLOW}(force mode — reapplying all configs)${NC}"
  echo -e "${YELLOW}Clearing caches...${NC}"
  rm -rf "$HOME/.zcompdump"* "$HOME/.cache/p10k-"* "$HOME/.zsh/cache" "$HOME/Library/Caches/antidote"
fi
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
  brew bundle --verbose --file="$REPO_DIR/Brewfile" || echo -e "${RED}Some Brewfile packages failed — continuing anyway.${NC}"
elif [[ -f /etc/arch-release ]]; then
  echo -e "${YELLOW}Installing with pacman...${NC}"
  sudo pacman -S --noconfirm bat dust duf fd lsd neovim ripgrep zoxide || echo -e "${RED}Some pacman packages failed — continuing anyway.${NC}"
elif [[ -f /etc/fedora-release ]]; then
  echo -e "${YELLOW}Installing with dnf...${NC}"
  sudo dnf install -y bat fd-find neovim ripgrep zoxide || echo -e "${RED}Some dnf packages failed — continuing anyway.${NC}"
elif [[ -f /etc/debian_version ]]; then
  echo -e "${YELLOW}Installing with apt...${NC}"
  sudo apt update && sudo apt install -y bat fd-find neovim ripgrep zoxide || echo -e "${RED}Some apt packages failed — continuing anyway.${NC}"
  [[ ! -L /usr/local/bin/bat ]] && sudo ln -sf "$(which batcat)" /usr/local/bin/bat 2>/dev/null || true
  [[ ! -L /usr/local/bin/fd ]]  && sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
else
  echo -e "${RED}Unknown OS. Install tools manually.${NC}"
fi

# --- Copy configs ---
echo
echo -e "${YELLOW}Installing config files...${NC}"

# Backup or remove existing configs
for target in "$HOME/.zshrc" "$HOME/.zsh" "$HOME/.config/git/config" "$HOME/.ssh/config" "$HOME/.tmux.conf" "$HOME/.screenrc"; do
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" ]]; then
      echo "  Removing symlink $target → $(readlink "$target")"
      rm -f "$target"
    elif $SKIP_BACKUP; then
      rm -rf "$target"
    else
      backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
      echo "  Backing up $target → $backup"
      mv "$target" "$backup"
    fi
  fi
done

cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
cp -R "$REPO_DIR/.zsh" "$HOME/.zsh"
cp "$REPO_DIR/.tmux.conf" "$HOME/.tmux.conf"
cp "$REPO_DIR/.screenrc" "$HOME/.screenrc"

# Git config (XDG standard — git reads ~/.config/git/config natively)
mkdir -p "$HOME/.config/git"
cp "$REPO_DIR/config/git/config" "$HOME/.config/git/config"

# SSH config
mkdir -p "$HOME/.ssh" "$HOME/.ssh/sockets"
chmod 700 "$HOME/.ssh"
if $FORCE || [[ ! -f "$HOME/.ssh/config" ]]; then
  cp "$REPO_DIR/config/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
fi

# Git user details (stored in ~/.gitconfig, separate from shared config)
if $FORCE || ! git config --file "$HOME/.gitconfig" user.name &>/dev/null; then
  echo
  echo -e "${YELLOW}Configure git identity:${NC}"
  read -rp "  Name:  " git_name
  read -rp "  Email: " git_email
  git config --file "$HOME/.gitconfig" user.name "$git_name"
  git config --file "$HOME/.gitconfig" user.email "$git_email"
fi

# --- bat theme ---
if command -v bat &>/dev/null; then
  echo -e "${YELLOW}Installing bat themes...${NC}"
  mkdir -p "$HOME/.config/bat/themes"
  cp "$REPO_DIR/config/bat/themes/"*.tmTheme "$HOME/.config/bat/themes/"
  bat cache --build
fi

# iTerm2 dynamic profile
if [[ "$OSTYPE" == darwin* && -d "/Applications/iTerm.app" ]]; then
  echo -e "${YELLOW}Installing iTerm2 profile...${NC}"
  DYNAMIC_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$DYNAMIC_DIR"
  if [[ ! "$REPO_DIR/iterm2_profile.json" -ef "$DYNAMIC_DIR/ZshModular.json" ]]; then
    cp "$REPO_DIR/iterm2_profile.json" "$DYNAMIC_DIR/ZshModular.json"
  fi
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "zsh-modular-profile"
fi

# --- Runtime directories ---
mkdir -p "$HOME/.zsh/cache"
[[ ! -f "$HOME/.zsh/local.zsh" ]] && echo "# Local overrides — not tracked in git" > "$HOME/.zsh/local.zsh"

# --- tmux plugin manager ---
if command -v tmux &>/dev/null; then
  if $FORCE || [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo -e "${YELLOW}Installing tmux plugin manager...${NC}"
    $FORCE && rm -rf "$HOME/.tmux/plugins/tpm"
    mkdir -p "$HOME/.tmux/plugins"
    if git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
      "$HOME/.tmux/plugins/tpm/bin/install_plugins" || echo -e "${RED}TPM plugin install failed — continuing anyway.${NC}"
    else
      echo -e "${RED}TPM clone failed — skipping.${NC}"
    fi
  fi
fi

# --- Neovim (LazyVim) ---
if $FORCE || [[ ! -d "$HOME/.config/nvim" ]]; then
  echo -e "${YELLOW}Installing LazyVim...${NC}"
  if $FORCE; then
    rm -rf "$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"
  fi
  if git clone --depth=1 https://github.com/LazyVim/starter "$HOME/.config/nvim"; then
    rm -rf "$HOME/.config/nvim/.git"
  else
    echo -e "${RED}LazyVim clone failed — skipping.${NC}"
  fi
fi

# --- Terminal.app font ---
if [[ "$OSTYPE" == darwin* ]]; then
  echo -e "${YELLOW}Setting Terminal.app font to JetBrainsMono Nerd Font...${NC}"
  osascript -e '
    tell application "Terminal"
      set font name of settings set "Basic" to "JetBrainsMonoNFM-Regular"
      set font size of settings set "Basic" to 14
    end tell' || echo -e "${RED}Terminal.app font set failed — set manually in Terminal > Preferences.${NC}"
fi

# --- VS Code terminal font ---
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
if [[ -f "$VSCODE_SETTINGS" ]]; then
  if ! grep -q 'terminal.integrated.fontFamily' "$VSCODE_SETTINGS"; then
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

# --- Claude Code settings ---
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
if $FORCE || [[ ! -f "$CLAUDE_SETTINGS" ]]; then
  echo -e "${YELLOW}Configuring Claude Code settings...${NC}"
  cp "$REPO_DIR/config/claude/settings.json" "$CLAUDE_SETTINGS"
fi

# --- OpenCode config ---
OPENCODE_DIR="$HOME/.config/opencode"
mkdir -p "$OPENCODE_DIR"
for f in opencode.json tui.json AGENTS.md; do
  target="$OPENCODE_DIR/$f"
  if $FORCE || [[ ! -f "$target" ]]; then
    if [[ -f "$target" ]] && ! $SKIP_BACKUP; then
      mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    cp "$REPO_DIR/config/opencode/$f" "$target"
  fi
done

# --- macOS defaults ---
if [[ "$OSTYPE" == darwin* && -f "$REPO_DIR/macos_defaults.sh" ]]; then
  echo
  bash "$REPO_DIR/macos_defaults.sh"
fi

# --- Record installed version ---
VERSION_FILE="$HOME/.local/share/mac-setup/installed.json"
mkdir -p "$(dirname "$VERSION_FILE")"
_version="$(git -C "$REPO_DIR" describe --exact-match --tags HEAD 2>/dev/null || git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo "unknown")"
cat > "$VERSION_FILE" << VEREOF
{
  "sha": "$_version",
  "branch": "$(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")",
  "date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "repo": "$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || echo "local")"
}
VEREOF

echo
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo
echo -e "Run ${YELLOW}exec zsh${NC} to reload your shell."
echo -e "Run ${YELLOW}p10k configure${NC} to set up your prompt."
echo -e "Enable ${YELLOW}VS Code Settings Sync${NC} for editor preferences."
echo
echo -e "${YELLOW}=== Install from the Mac App Store ===${NC}"
echo "  Wins · Perplexity · Plex · Plex Dash · Messenger · Telegram · WhatsApp"
echo
echo -e "Font: ${YELLOW}JetBrainsMono Nerd Font${NC} (terminal + VS Code)"
