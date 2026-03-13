# Aliases and utility functions

# --- Modern CLI replacements ---
command -v lsd   &>/dev/null && alias ls='lsd'
if command -v bat &>/dev/null; then
  alias cat='bat'
  export BAT_THEME="Monokai Extended"
  export BAT_STYLE="numbers,changes,header"
fi
command -v dust  &>/dev/null && alias du='dust'
command -v duf   &>/dev/null && alias df='duf'
command -v rg    &>/dev/null && alias grep='rg'
command -v doggo &>/dev/null && alias nslookup='doggo'
command -v gping &>/dev/null && alias ping='gping'
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
