#!/bin/sh
# lang/javascript.sh -- JavaScript/TypeScript: language server and tooling, via uv.
HERE=$(cd "$(dirname "$0")/.." && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Install JavaScript/TypeScript tooling under ~/.local.'
parse_flags "$@"

choose "$(missing uv typescript-language-server deno Prettier eslint_d prettier_d)"
install_chosen