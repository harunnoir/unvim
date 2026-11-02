#!/bin/sh
# lang/go.sh -- Go: gopls and gofumpt. Go itself is yours to install.
HERE=$(cd "$(dirname "$0")/.." && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Install Go tooling into ~/go/bin.'
parse_flags "$@"

has go || die 'Go is required. Unpack the tarball from https://go.dev/dl/ into ~/.local/go (no root needed) and add ~/.local/go/bin to PATH.'

choose "$(missing gopls gofumpt parser_go parser_gomod)"
install_chosen
