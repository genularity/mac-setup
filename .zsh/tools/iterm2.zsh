[[ "$TERM_PROGRAM" == "iTerm.app" ]] || return

# Per-repo background tint — each repo gets a unique subtle hue based on its path
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
