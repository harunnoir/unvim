#!/bin/sh
# doctor.sh -- report what is installed and what is missing. Changes nothing.
# Exits non-zero if something the config needs to start is missing.
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Check the core tools and each language.'
parse_flags "$@"
FAILED=0

# check LABEL COMMAND required|optional HINT
check() {
    if has "$2"; then
        printf '  ok       %-16s %s\n' "$1" "$(command -v "$2")"
    else
        printf '  missing  %-16s %s\n' "$1" "$4"
        if [ "$3" = required ]; then FAILED=1; fi
    fi
}

say 'Core'
if nvim_ok; then
    printf '  ok       %-16s %s\n' neovim "$(nvim --version | head -n 1)"
else
    printf '  missing  %-16s %s\n' 'neovim 0.12+' 'run sh/install.sh'
    FAILED=1
fi
check git git required 'install with your package manager'
if has cc || has gcc || has clang; then
    printf '  ok       %-16s\n' 'C compiler'
else
    printf '  missing  %-16s %s\n' 'C compiler' 'install build-essential (or your distro equivalent)'
    FAILED=1
fi
check ripgrep rg required 'run sh/install.sh'
check fd fd required 'run sh/install.sh'
check tree-sitter tree-sitter required 'run sh/install.sh'
check lazygit lazygit optional 'run sh/install.sh (optional)'

say 'C and C++   (sh/lang/c.sh)'
check clangd clangd optional 'run sh/lang/c.sh'
check c_formatter_42 c_formatter_42 optional 'run sh/lang/c.sh'
check norminette norminette optional 'run sh/lang/c.sh'

say 'Python      (sh/lang/python.sh)'
check uv uv optional 'run sh/lang/python.sh'
check basedpyright basedpyright-langserver optional 'run sh/lang/python.sh'
check flake8 flake8 optional 'run sh/lang/python.sh'
check autopep8 autopep8 optional 'run sh/lang/python.sh'
check docformatter docformatter optional 'run sh/lang/python.sh'

say 'Go          (sh/lang/go.sh)'
check go go optional 'install from https://go.dev/dl/'
check gopls gopls optional 'run sh/lang/go.sh'
check gofumpt gofumpt optional 'run sh/lang/go.sh'

exit "$FAILED"
