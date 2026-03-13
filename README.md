# mac-setup

Automated provisioning for a fresh Mac. One script installs Homebrew packages, configures zsh with Powerlevel10k, sets git defaults, applies macOS system preferences, and drops in an iTerm2 profile.

## Usage

```bash
git clone https://github.com/genularity/mac-setup.git ~/code/mac-setup
cd ~/code/mac-setup
bash install.sh
```

Run from **Terminal.app**, not iTerm2 — the script modifies iTerm2 settings.

After install, run `exec zsh` to reload your shell and `p10k configure` to set up your prompt.

## What it does

### Packages (Brewfile)

CLI tools: `bat`, `btop`, `claude-code`, `curl`, `doggo`, `duf`, `dust`, `fd`, `gh`, `git`, `gping`, `helm`, `httpie`, `jq`, `k9s`, `kubectx`, `kubernetes-cli`, `lsd`, `neovim`, `podman`, `procs`, `ripgrep`, `rsync`, `uv`, `watch`, `wget`, `zoxide`

GNU tools: `coreutils`, `findutils`, `gnu-tar`, `gnu-sed`, `gawk`, `grep`

Fonts: JetBrains Mono Nerd Font, Meslo LG Nerd Font

Apps: AppCleaner, ChatGPT, Claude, CleanShot, Firefox, Google Chrome, Ice, IINA, iTerm2, Obsidian, Perplexity, Podman Desktop, VLC

VS Code extensions: Ruff, Path Intellisense, markdownlint, Prettier, Todo Tree, Terraform, Kubernetes, Python, Material Icon Theme, YAML, Markdown Preview Enhanced, Even Better TOML, Error Lens

### Zsh

Plugin manager: [Antidote](https://getantidote.github.io)

Plugins: Powerlevel10k, zsh-completions, zsh-autosuggestions, zsh-history-substring-search, zsh-autopair, zsh-nvm, F-Sy-H (syntax highlighting)

Modern CLI aliases: `ls` → lsd, `cat` → bat, `du` → dust, `df` → duf, `grep` → rg, `nslookup` → doggo, `ping` → gping, `vi`/`vim` → nvim

### Git config

Installs to `~/.config/git/config` with: histogram diffs, zdiff3 merge conflicts, auto-setup remote on push, pull with rebase, fetch with prune, rerere, and common aliases.

### macOS defaults

Faster key repeat, Finder tweaks (extensions, path bar, list view, search current folder), curated Dock, natural scroll disabled, screenshots to `~/Screenshots`, no .DS_Store on network/USB volumes, expanded save/print panels.

### iTerm2

Installs a dynamic profile with the configured theme and Nerd Font.

## Structure

```
.zshrc                  # Entry point — instant prompt + sources init.zsh
.zsh/
  init.zsh              # Orchestrator — loads everything in order
  options.zsh           # PATH, env, shell options, history
  completions.zsh       # Completion system setup
  aliases.zsh           # Aliases and shell functions
  plugins.txt           # Antidote plugin list
  p10k.zsh              # Powerlevel10k config
  macos.zsh             # macOS-specific settings
  tools/                # Per-tool configs (aws, go, k8s, node, terraform, uv, zoxide)
config/
  git/config            # Git configuration
Brewfile                # Homebrew packages, casks, and VS Code extensions
install.sh              # Main install script
macos_defaults.sh       # macOS system preferences
iterm2_profile.json     # iTerm2 dynamic profile
```

## Customization

- `~/.zsh/local.zsh` — machine-specific overrides (gitignored, created automatically)
- `~/.p10k.zsh` — local Powerlevel10k override (takes precedence over the repo's `p10k.zsh`)

## Updating plugins

```bash
zsh-update-plugins
```

## Manual post-install

Install from the Mac App Store: Wins, 1Password, Plex, Plex Dash, Messenger, Telegram, WhatsApp

Enable VS Code Settings Sync for editor preferences.
