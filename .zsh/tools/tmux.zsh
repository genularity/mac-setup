if command -v tmux &>/dev/null; then
  # Attach to existing session or create a new one
  alias t='tmux attach 2>/dev/null || tmux new-session'
  alias ta='tmux attach -t'
  alias tl='tmux list-sessions'
  alias tn='tmux new-session -s'
  alias tk='tmux kill-session -t'
fi
