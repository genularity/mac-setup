# Aliases and utility functions

# --- Modern CLI replacements ---
command -v lsd   &>/dev/null && alias ls='lsd'
if command -v bat &>/dev/null; then
  alias cat='bat'
  export BAT_THEME="tokyonight_night"
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

# Per-repo background tint for iTerm2 — each repo gets a unique subtle hue
_git_bg_tint() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf "\033]1337;SetColors=bg=1e1e1e\a"
    return
  }
  local hash=$(printf '%s' "$root" | md5)
  local raw_hue=$(( 16#${hash[1,4]} % 360 ))
  local hue=$(( 30 + raw_hue * 300 / 360 ))
  local s=15 l=10
  local c=$(( (100 - (2*l - 100 < 0 ? 100 - 2*l : 2*l - 100)) * s / 100 ))
  local h_prime=$(( hue * 100 / 60 ))
  local x_raw=$(( h_prime % 200 ))
  (( x_raw > 100 )) && x_raw=$(( 200 - x_raw ))
  local x=$(( c * x_raw / 100 ))
  local m=$(( (l * 255 / 100) - (c * 255 / 200) ))
  local r g b
  if   (( hue < 60 ));  then r=$c g=$x b=0
  elif (( hue < 120 )); then r=$x g=$c b=0
  elif (( hue < 180 )); then r=0  g=$c b=$x
  elif (( hue < 240 )); then r=0  g=$x b=$c
  elif (( hue < 300 )); then r=$x g=0  b=$c
  else                        r=$c g=0  b=$x
  fi
  r=$(( r * 255 / 100 + m ))
  g=$(( g * 255 / 100 + m ))
  b=$(( b * 255 / 100 + m ))
  printf "\033]1337;SetColors=bg=%02x%02x%02x\a" $r $g $b
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _git_bg_tint
_git_bg_tint

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
