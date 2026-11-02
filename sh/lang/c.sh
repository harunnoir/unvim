#!/bin/sh
# lang/c.sh -- C and C++: clangd, plus the 42 formatter and Norminette.
HERE=$(cd "$(dirname "$0")/.." && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Install C/C++ tooling under ~/.local.'
parse_flags "$@"

has cc || has gcc || has clang || die 'a C compiler is required (for example: sudo apt install build-essential)'
has c++ || has g++ || has clang++ || warn 'no C++ compiler found: C works, C++ will not'

choose "$(missing uv clangd c_formatter_42 norminette parser_cpp parser_make)"
install_chosen
