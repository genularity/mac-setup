command -v uv &>/dev/null || return
eval "$(uv generate-shell-completion zsh)"
