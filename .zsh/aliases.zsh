# Aliases and utility functions

# --- Modern CLI replacements ---
command -v lsd   &>/dev/null && alias ls='lsd'
command -v bat &>/dev/null && alias cat='bat'
command -v dust  &>/dev/null && du() {
  local args=()
  for a in "$@"; do [[ "$a" == -* ]] && [[ -z "${a//[-sh]/}" ]] || args+=("$a"); done
  dust "${args[@]}"
}
command -v duf   &>/dev/null && df() {
  local args=()
  for a in "$@"; do [[ "$a" == -h ]] || args+=("$a"); done
  duf "${args[@]}"
}
command -v doggo &>/dev/null && alias nslookup='doggo' dig='doggo'
command -v nvim &>/dev/null && alias vi='nvim' vim='nvim' v='nvim'

# --- Functions ---

mkcd() { mkdir -p "$1" && cd "$1" }

# Profiling helpers
zsh-profile-start() { zmodload zsh/zprof }
zsh-profile-stop()  { zprof }

# Update all antidote plugins
zsh-update-plugins() {
  antidote update
  exec zsh
}

# Kill all Claude Code processes (agents, subagents, background tasks)
killallclaude() {
  pkill -f 'claude' 2>/dev/null
  echo "Killed all Claude processes"
}

# Claude Code — always start with tmux teammate mode for agent teams (iTerm2 split panes)
claude() { command claude --teammate-mode tmux "$@" }
