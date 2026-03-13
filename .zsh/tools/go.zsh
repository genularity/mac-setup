if command -v goenv &>/dev/null; then
  export GOENV_ROOT="$HOME/.goenv"
  path=("$GOENV_ROOT/bin" $path)
  eval "$(goenv init -)"
  path=("$GOROOT/bin" $path "$GOPATH/bin")
fi
