# Completion system — single compinit, all zstyle rules

# Homebrew completions (hardcoded path avoids slow `brew --prefix` call)
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

# Keg-only tools (not auto-linked by Homebrew)
if [[ -d /opt/homebrew/opt/curl/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/opt/curl/share/zsh/site-functions $fpath)
fi

# Initialize compinit (regenerate dump every 24h)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Bash completion compatibility (needed by tools like aws, terraform, httpie)
autoload -U +X bashcompinit && bashcompinit
[[ -f /opt/homebrew/etc/bash_completion.d/httpie ]] && source /opt/homebrew/etc/bash_completion.d/httpie

# --- Styles ---
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' squeeze-slashes true

# Grouping
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''

# Directories
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' menu yes

# Man pages
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:man:*' menu yes select

# Keybindings for history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
