# Aliases and utility functions

# --- Modern CLI replacements ---
command -v lsd   &>/dev/null && alias ls='lsd'
if command -v bat &>/dev/null; then
  alias cat='bat'
  export BAT_THEME="TwoDark"
  export BAT_STYLE="numbers,changes,header"
fi
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
    wobbly cranky chonky sneaky grumpy zappy bouncy fizzy wonky sassy
    fluffy dizzy snappy quirky nippy zippy jolly bonkers cheeky dapper
    frisky giddy lanky plucky shifty spunky wacky yappy cosmic groovy
    turbo mega ultra hyper funky punky crispy crunchy tangy salty
    spicy breezy dusty rusty glossy frosty toasty gritty nifty witty
  )
  local animals=(
    quokka platypus wombat echidna bilby numbat quoll bandicoot
    cassowary kookaburra cockatoo galah lorikeet budgie emu
    goanna thornydevil taipan dugong barramundi lyrebird bettong
    potoroo pademelon dingo wallaby koala possum glider sugar-glider
    crocodile frillneck bluetongue redback huntsman magpie currawong
    ibis brolga jabiru pelican penguin boobook tawny-frogmouth
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
