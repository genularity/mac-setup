# Auto-switch macOS wallpaper based on .wallpaper symlink in git repo root
# Note: sets wallpaper on the primary display only. Multi-display not implemented.

command -v desktoppr &>/dev/null || return

_WALLPAPER_DEFAULT=$(desktoppr 2>/dev/null)
_WALLPAPER_ACTIVE=0

_wallpaper_sync() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -n "$root" && -L "$root/.wallpaper" ]]; then
    local target="$root/.wallpaper"
    target=${target:A}
    if [[ -f "$target" ]]; then
      desktoppr "$target" 2>/dev/null
      _WALLPAPER_ACTIVE=1
    fi
  elif (( _WALLPAPER_ACTIVE )); then
    if [[ -n "$_WALLPAPER_DEFAULT" ]]; then
      desktoppr "$_WALLPAPER_DEFAULT" 2>/dev/null
    fi
    _WALLPAPER_ACTIVE=0
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _wallpaper_sync
_wallpaper_sync

wp() {
  local cmd=$1
  case $cmd in
    set)
      if [[ -z "$2" ]]; then
        echo "Usage: wp set <image-path>" >&2
        return 1
      fi
      local root
      root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "wp: not inside a git repo" >&2
        return 1
      }
      local img=${2:A}
      if [[ ! -f "$img" ]]; then
        echo "wp: image not found: $2" >&2
        return 1
      fi
      ln -sf "$img" "$root/.wallpaper"
      echo "Wallpaper set → $img"
      _wallpaper_sync
      ;;
    clear)
      local root
      root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "wp: not inside a git repo" >&2
        return 1
      }
      if [[ -L "$root/.wallpaper" ]]; then
        rm "$root/.wallpaper"
        echo "Wallpaper cleared"
        _WALLPAPER_ACTIVE=0
        if [[ -n "$_WALLPAPER_DEFAULT" ]]; then
          desktoppr "$_WALLPAPER_DEFAULT" 2>/dev/null
        fi
      else
        echo "wp: no .wallpaper symlink found in $root" >&2
        return 1
      fi
      ;;
    ""|*)
      echo "Usage: wp set <image-path> | wp clear" >&2
      return 1
      ;;
  esac
}
