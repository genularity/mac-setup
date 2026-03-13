if command -v kubectl &>/dev/null; then
  alias k=kubectl
  compdef k=kubectl
fi

if command -v kubectx &>/dev/null; then
  alias kctx=kubectx kns=kubens
fi

# Merge all kubeconfigs from ~/.kube/*.{yaml,yml}
() {
  local configs=()
  setopt local_options nullglob
  for f in "$HOME/.kube"/*.yaml "$HOME/.kube"/*.yml; do
    [[ -f "$f" && -r "$f" ]] && configs+=("$f")
  done
  (( $#configs )) && export KUBECONFIG="${(j.:.)configs}"
}
