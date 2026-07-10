# Optional p10k module: per-folder directory icons + .dirglyph marker
# override. Fully self-contained — sourced from ~/.zsh/p10k.zsh inside its
# config function. To disable: delete or rename this file and reload the
# shell (`exec zsh`); p10k falls back to its stock single dir icon with no
# other changes required. Requires POWERLEVEL9K_DIR_SHOW_WRITABLE=v3 (set
# in p10k.zsh) for the not-writable/non-existent lock-icon states below to
# apply; harmless (just inert) if that's ever removed.
#
# macOS-only assumption: the paths below (~/Library/Mobile Documents/...)
# are Apple-specific. On Linux this file is simply a no-op set of dead
# glob patterns (they won't match anything) — safe to source unconditionally,
# but there's nothing Linux-specific to gain from it either.

# ICLOUD must precede LIBRARY: p10k matches DIR_CLASSES in order and stops
# at the first hit, and LIBRARY's glob also matches the iCloud subtree
# (~/Library/Mobile Documents/...), so the more specific pattern has to
# come first or it's unreachable.
typeset -g POWERLEVEL9K_DIR_CLASSES=(
  '~'                       HOME          ''
  '~/Desktop(|/*)'          DESKTOP       ''
  '~/Downloads(|/*)'        DOWNLOADS     ''
  '~/Documents(|/*)'        DOCUMENTS     ''
  '~/Music(|/*)'            MUSIC         ''
  '~/Pictures(|/*)'         PICTURES      ''
  '~/Movies(|/*)'           MOVIES        ''
  '~/Applications(|/*)'     APPLICATIONS  ''
  '~/Library/Mobile Documents/com~apple~CloudDocs(|/*)' ICLOUD ''
  '~/Library(|/*)'          LIBRARY       ''
  '~/*'                     HOME_SUBFOLDER ''
  '*'                       DEFAULT       ''
)

# Subtle distinction for read-only / non-existent dirs (icon already
# switches to lock glyph via SHOW_WRITABLE=v3; background stays the same,
# only the foreground tints so it's noticeable, not alarming). NOTE: with
# POWERLEVEL9K_DIR_CLASSES set, p10k's state becomes DIR_<CLASS>_NOT_WRITABLE,
# which falls back to DIR_<CLASS>_FOREGROUND, NOT the generic
# DIR_NOT_WRITABLE_FOREGROUND — must set per class.
for _p10k_dir_class in HOME DESKTOP DOWNLOADS DOCUMENTS MUSIC PICTURES \
    MOVIES APPLICATIONS LIBRARY ICLOUD HOME_SUBFOLDER DEFAULT; do
  typeset -g POWERLEVEL9K_DIR_${_p10k_dir_class}_NOT_WRITABLE_FOREGROUND=178
  typeset -g POWERLEVEL9K_DIR_${_p10k_dir_class}_NOT_WRITABLE_ANCHOR_FOREGROUND=178
  typeset -g POWERLEVEL9K_DIR_${_p10k_dir_class}_NON_EXISTENT_FOREGROUND=167
  typeset -g POWERLEVEL9K_DIR_${_p10k_dir_class}_NON_EXISTENT_ANCHOR_FOREGROUND=167
done
unset _p10k_dir_class

# Icon resolution below is a two-layer indirection so a .dirglyph marker
# file (see the precmd hook further down) can override the icon LIVE,
# every render, without ever touching a POWERLEVEL9K_* param. p10k
# invalidates its entire cache (and restarts gitstatusd) whenever any
# POWERLEVEL9K_* value changes between renders — a naive "mutate the icon
# var on cd" design would trigger a full reinit on every transition
# into/out of a marked or read-only directory. Instead, each class's
# _VISUAL_IDENTIFIER_EXPANSION is a STATIC template (set once, below,
# never touched again) that references a private, non-prefixed scalar
# (_p10k_dirglyph_override). Only that private scalar changes per
# directory; the template itself — and therefore p10k's param signature —
# never does, so no reinit, and the override still applies live because
# zsh evaluates ${...} template references at prompt render time, not at
# the point p10k cached the template string.
typeset -g _p10k_dirglyph_override=''
typeset -g POWERLEVEL9K_DIR_HOME_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf015}'
typeset -g POWERLEVEL9K_DIR_DESKTOP_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf108}'
typeset -g POWERLEVEL9K_DIR_DOWNLOADS_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf019}'
typeset -g POWERLEVEL9K_DIR_DOCUMENTS_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf1c2}'
typeset -g POWERLEVEL9K_DIR_MUSIC_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf001}'
typeset -g POWERLEVEL9K_DIR_PICTURES_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf03e}'
typeset -g POWERLEVEL9K_DIR_MOVIES_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf03d}'
typeset -g POWERLEVEL9K_DIR_APPLICATIONS_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf1d5}'
typeset -g POWERLEVEL9K_DIR_LIBRARY_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf1c0}'
typeset -g POWERLEVEL9K_DIR_ICLOUD_VISUAL_IDENTIFIER_EXPANSION=$'${_p10k_dirglyph_override:-\uf0c2}'
# HOME_SUBFOLDER/DEFAULT have no icon of their own by default (p10k falls
# back to its built-in FOLDER_ICON) — only apply the override, never force
# an icon when there's no marker.
typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_VISUAL_IDENTIFIER_EXPANSION='${_p10k_dirglyph_override:-${P9K_VISUAL_IDENTIFIER}}'
typeset -g POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_EXPANSION='${_p10k_dirglyph_override:-${P9K_VISUAL_IDENTIFIER}}'
# Not-writable / non-existent: p10k already swaps the icon to its lock
# glyph for these states (via POWERLEVEL9K_DIR_SHOW_WRITABLE=v3). Prefix
# the marker glyph in front of that lock icon when one is set, so both
# signals show together; otherwise just the lock, unchanged.
for _p10k_dir_class in HOME DESKTOP DOWNLOADS DOCUMENTS MUSIC PICTURES \
    MOVIES APPLICATIONS LIBRARY ICLOUD HOME_SUBFOLDER DEFAULT; do
  typeset -g POWERLEVEL9K_DIR_${_p10k_dir_class}_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION='${_p10k_dirglyph_override:+$_p10k_dirglyph_override }${P9K_VISUAL_IDENTIFIER}'
  typeset -g POWERLEVEL9K_DIR_${_p10k_dir_class}_NON_EXISTENT_VISUAL_IDENTIFIER_EXPANSION='${_p10k_dirglyph_override:+$_p10k_dirglyph_override }${P9K_VISUAL_IDENTIFIER}'
done
unset _p10k_dir_class

# === dir: .dirglyph marker-file icon override ===
# A file named .dirglyph in $PWD or any ancestor (up to /) overrides the
# classified icon set above. First line of the file (trimmed) is the
# glyph; closest ancestor wins. Only the private _p10k_dirglyph_override
# scalar is touched per directory (see the VISUAL_IDENTIFIER_EXPANSION
# templates above) — never a POWERLEVEL9K_* param — so this never
# triggers p10k's reinit-on-param-change machinery, and the override is
# re-evaluated live on every prompt render regardless of caching.
# Symlinks are rejected (not followed) — a marker can only be a plain
# regular file, so it can't be pointed at an arbitrary file elsewhere
# (e.g. a private key) to leak its first line into the prompt.
function _p10k_dirglyph_precmd() {
  emulate -L zsh -o extended_glob
  local dir=$PWD glyph=''
  while :; do
    if [[ -f $dir/.dirglyph && ! -L $dir/.dirglyph && -r $dir/.dirglyph ]]; then
      local lines=(${(f)"$(<$dir/.dirglyph 2>/dev/null)"})
      glyph=${lines[1]}
      glyph=${glyph##[[:space:]]#}
      glyph=${glyph%%[[:space:]]#}
      break
    fi
    [[ $dir == / ]] && break
    dir=${dir%/*}
    [[ -z $dir ]] && dir=/
  done
  _p10k_dirglyph_override="$glyph"
}
_p10k_dirglyph_precmd  # prime before the first prompt ever renders
autoload -Uz add-zsh-hook
add-zsh-hook precmd _p10k_dirglyph_precmd
