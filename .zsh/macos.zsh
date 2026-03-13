# macOS-specific configuration

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# VS Code CLI
[[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]] \
  && path+=("/Applications/Visual Studio Code.app/Contents/Resources/app/bin")

# GNU tools (prefer over BSD)
local -a gnu_tools=(coreutils findutils gnu-tar gnu-sed gawk grep)
for tool in $gnu_tools; do
  local gnubin="/opt/homebrew/opt/$tool/libexec/gnubin"
  [[ -d "$gnubin" ]] && path=("$gnubin" $path)
done
[[ -d "/opt/homebrew/opt/coreutils/libexec/gnuman" ]] \
  && export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH"

# macOS aliases
alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# iTerm2 shell integration
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"
