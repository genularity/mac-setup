# Shell options, environment, history, PATH

# --- PATH ---
typeset -U path fpath  # deduplicate
path=(
  $HOME/.local/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/bin
  $path
)

# --- Environment ---
export EDITOR="${${commands[nvim]:+nvim}:-vi}"
export VISUAL="$EDITOR"
export PAGER='less'
export LESS='-R'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export NVM_LAZY_LOAD=true
umask 022

# --- Directory navigation ---
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

# --- Input/output ---
setopt interactive_comments
setopt no_clobber
setopt correct
setopt no_flow_control
setopt rc_quotes

# --- Job control ---
setopt auto_resume
setopt notify
setopt long_list_jobs

# --- Completion ---
setopt always_to_end
setopt auto_menu
setopt complete_in_word
setopt no_menu_complete
setopt no_complete_aliases

# --- Globbing ---
setopt extended_glob
setopt glob_dots
setopt no_case_glob
setopt numeric_glob_sort

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
