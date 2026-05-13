# mkt — create and cd into a /tmp dir with a random name + emoji pair

typeset -gA _mkt_adjective_emoji=(
  electric    "⚡"
  scorching   "🔥"
  dazed       "💫"
  loopy       "🌀"
  exploding   "💥"
  sparkly     "✨"
  hypersonic  "⏩"
  disco       "🪩"
)

typeset -gA _mkt_noun_emoji=(
  kangaroo          "🦘"
  koala             "🐨"
  crocodile         "🐊"
  shark             "🦈"
  funnel-web-spider "🕷️"
  tiger-snake       "🐍"
  echidna           "🦔"
  surfer            "🏄"
  bbq               "🍖"
  ufo               "🛸"
  circus            "🎪"
  beer              "🍺"
  paramotor         "🪂"
  ninja             "🥷"
)

# Create and cd into a /tmp dir with a random adjective-noun name
mkt() {
  local adjectives=( ${(k)_mkt_adjective_emoji} )
  local nouns=( ${(k)_mkt_noun_emoji} )
  local dir attempts=0
  while (( attempts++ < 100 )); do
    local adj=${adjectives[$((RANDOM % ${#adjectives[@]} + 1))]}
    local noun=${nouns[$((RANDOM % ${#nouns[@]} + 1))]}
    dir="/tmp/${adj}-${noun}"
    [[ ! -e "$dir" ]] && break
  done
  if [[ -e "$dir" ]]; then
    echo "mkt: couldn't find a unique name after 100 attempts" >&2
    return 1
  fi
  mkdir "$dir" && cd "$dir" && echo "$dir"
}

# Walk up the path looking for a segment that matches adjective-noun from the lists.
# Sets _mkt_pair (emoji) and _mkt_name (dir basename) in the caller's scope, or empty.
_mkt_lookup() {
  _mkt_pair=''
  _mkt_name=''
  local dir=$PWD
  while [[ $dir != '/' ]]; do
    local base=${dir:t}
    local adj=${base%%-*}
    local noun=${base#*-}
    local ae=${_mkt_adjective_emoji[$adj]}
    local ne=${_mkt_noun_emoji[$noun]}
    if [[ -n $ae && -n $ne ]]; then
      _mkt_pair="${ae}${ne}"
      _mkt_name="$base"
      return
    fi
    dir=${dir:h}
  done
}

# p10k custom segment — always defined so p10k never errors
function prompt_mkt_emoji() {
  local _mkt_pair _mkt_name
  _mkt_lookup
  [[ -z $_mkt_pair ]] && return
  p10k segment -t "$_mkt_pair"
}

# Window title hook — set iTerm2 title to emoji+name inside mkt dirs, else $PWD
_mkt_title() {
  local _mkt_pair _mkt_name
  _mkt_lookup
  if [[ -n $_mkt_pair ]]; then
    printf '\e]0;%s %s\a' "$_mkt_pair" "$PWD"
  else
    printf '\e]0;%s\a' "$PWD"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _mkt_title
