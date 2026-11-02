#!/bin/sh
# install.sh -- the bare minimum for this config to work. Run it first.
# It shows what it will do, asks before doing it, and never uses root.
# Language tools are separate: see sh/lang/.
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Install Neovim 0.12+, the config and its core tools under ~/.local.'
parse_flags "$@"

say '1/4  System requirements (I only check these: they need your package manager)'
lacking=''
for cmd in git tar gzip; do has "$cmd" || lacking="$lacking $cmd"; done
has curl || has wget || lacking="$lacking curl"
has cc || has gcc || has clang || lacking="$lacking a-C-compiler"
if [ -n "$lacking" ]; then
    warn "missing:$lacking"
    say "  Install them (for example: sudo apt install git curl build-essential), then run this again."
    [ "$DRY_RUN" = 1 ] || exit 1
else
    say '  all present'
fi

say '2/4  Tools'
choose "$(missing nvim rg fd tree_sitter lazygit)"
install_chosen
if ! nvim_ok; then
    warn 'Neovim 0.12 or newer is not installed.'
    say '  Install it yourself (https://github.com/neovim/neovim/blob/master/INSTALL.md)'
    say '  or run this script again and answer yes when it offers Neovim.'
    [ "$DRY_RUN" = 1 ] || exit 1
fi

CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
say "3/4  Config location ($CONFIG)"
here=$(cd "$ROOT" && pwd -P)
there=$(cd "$CONFIG" 2>/dev/null && pwd -P)
if [ "$here" = "$there" ]; then
    say '  already in place'
elif [ "$DRY_RUN" = 1 ]; then
    say "  would link $ROOT -> $CONFIG (an existing one is renamed, not deleted)"
elif ask "  Link $ROOT to $CONFIG?"; then
    mkdir -p "$(dirname "$CONFIG")"
    if [ -e "$CONFIG" ] || [ -L "$CONFIG" ]; then mv "$CONFIG" "$CONFIG.bak.$(date +%Y%m%d%H%M%S)"; fi
    ln -s "$ROOT" "$CONFIG"
    say '  linked'
else
    say '  skipped; plugins need the config at that path'
fi

say '4/4  Plugins (Neovim fetches them itself and pins them in nvim-pack-lock.json)'
there=$(cd "$CONFIG" 2>/dev/null && pwd -P)
if [ "$DRY_RUN" = 1 ]; then
    say '  would run: nvim --headless +qa'
elif [ "$here" != "$there" ]; then
    say '  skipped: config not in place'
elif ask '  Fetch the plugins now?'; then
    NVIM_INSTALL=1 nvim --headless +qa
fi

case ":$PATH:" in
    *":$BIN:"*) ;;
    *) say "Add this to your shell profile so tools in $BIN are found:"
       say "  export PATH=\"$BIN:\$PATH\"" ;;
esac
say 'Done. Next: sh/doctor.sh to check, then sh/lang/c.sh, python.sh or go.sh for languages.'
