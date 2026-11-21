#!/bin/sh
# lang/rust.sh -- Rust: language server and tooling, via uv and cargo.
HERE=$(cd "$(dirname "$0")/.." && pwd)
. "$HERE/lib.sh"
. "$HERE/tools.sh"

SUMMARY='Install Rust tooling under ~/.local.'
parse_flags "$@"

choose "$(missing rust-analyzer cargo fmt clippy)"
install_chosen