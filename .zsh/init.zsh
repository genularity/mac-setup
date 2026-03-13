# Main orchestrator — sources everything in explicit order

source ~/.zsh/options.zsh

# Plugins via antidote
if [[ -f ${ZDOTDIR:-~}/.antidote/antidote.zsh ]]; then
  source ${ZDOTDIR:-~}/.antidote/antidote.zsh
elif [[ -f /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
fi

if (( $+functions[antidote] )); then
  antidote load ~/.zsh/plugins.txt
fi

source ~/.zsh/completions.zsh
source ~/.zsh/aliases.zsh

[[ "$OSTYPE" == darwin* ]] && source ~/.zsh/macos.zsh

# Source tool configs for installed tools
for f in ~/.zsh/tools/*.zsh(N); do
  source "$f"
done

# User overrides (not tracked in git)
[[ -f ~/.zsh/local.zsh ]] && source ~/.zsh/local.zsh
