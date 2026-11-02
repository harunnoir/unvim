#!/bin/sh
# lang/python.sh -- Python: language server, linter and formatters, via uv.
HERE=$(cd "$(dirname "$0")/.." && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Install Python tooling under ~/.local.'
parse_flags "$@"

choose "$(missing uv basedpyright flake8 autopep8 docformatter parser_python)"
install_chosen
