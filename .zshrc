# Enable Powerlevel10k instant prompt (must stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/.zsh/init.zsh

# Source p10k config (local override takes precedence)
if [[ -f ~/.p10k.zsh ]]; then
  source ~/.p10k.zsh
else
  source ~/.zsh/p10k.zsh
fi
