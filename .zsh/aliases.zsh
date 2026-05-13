# Aliases and utility functions

# --- Modern CLI replacements ---
command -v lsd   &>/dev/null && alias ls='lsd'
command -v bat &>/dev/null && alias cat='bat'
command -v dust  &>/dev/null && alias du='dust'
command -v duf   &>/dev/null && alias df='duf'
command -v rg    &>/dev/null && alias grep='rg'
command -v doggo &>/dev/null && alias nslookup='doggo' dig='doggo'
command -v gping &>/dev/null && alias ping='gping'
command -v nvim &>/dev/null && alias vi='nvim' vim='nvim' v='nvim'

# --- Functions ---

mkcd() { mkdir -p "$1" && cd "$1" }

# Create and cd into a /tmp dir with a random Docker-style name
mkt() {
  local adjectives=(
    wobbly chonky zappy bouncy fizzy wonky sassy fluffy dizzy snappy
    quirky zippy jolly bonkers cheeky dapper frisky giddy plucky spunky
    wacky cosmic groovy turbo mega hyper funky toasty nifty witty
    breezy glossy bubbly peppy zesty perky snazzy jazzy spiffy
    chipper giggly wiggly sparkly squiggly floofy cuddly sprightly dandy
  )
  local animals=(
    kangaroo koala platypus echidna wombat quokka wallaby dingo
    emu kookaburra cockatoo galah
    tasmanian-devil sugar-glider frillneck goanna dugong bilby
    barramundi magpie ibis
    crocodile king-brown-snake tiger-snake redback-spider funnel-web-spider
    shark box-jellyfish stonefish bluebottle blue-ringed-octopus huntsman-spider
  )
  local dir attempts=0
  while (( attempts++ < 100 )); do
    local adj=${adjectives[$((RANDOM % ${#adjectives[@]} + 1))]}
    local animal=${animals[$((RANDOM % ${#animals[@]} + 1))]}
    dir="/tmp/${adj}-${animal}"
    [[ ! -e "$dir" ]] && break
  done
  if [[ -e "$dir" ]]; then
    echo "mkt: couldn't find a unique name after 100 attempts" >&2
    return 1
  fi
  mkdir "$dir" && cd "$dir" && echo "$dir"
}


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
