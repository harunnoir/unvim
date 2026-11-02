# lib.sh -- helpers shared by every script in sh/. Source it; never run it.
# POSIX sh only. Nothing here uses root: everything goes under ~/.local.
# The sourcing script sets HERE (the sh/ directory) before sourcing this file.

BIN=${XDG_BIN_HOME:-$HOME/.local/bin}
SHARE=${XDG_DATA_HOME:-$HOME/.local/share}
ROOT=$(cd "$HERE/.." && pwd)
PATH="$BIN:$HOME/go/bin:$PATH"
ASSUME_YES=0
DRY_RUN=0

case $(uname -s) in Linux) OS=linux ;; Darwin) OS=macos ;; *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;; esac
case $(uname -m) in x86_64 | amd64) CPU=x86_64 ;; aarch64 | arm64) CPU=arm64 ;; *) echo "unsupported CPU: $(uname -m)" >&2; exit 1 ;; esac

say() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

usage() { printf 'Usage: %s [-y|--yes] [-n|--dry-run] [-h|--help]\n  %s\n' "$0" "${SUMMARY:-}"; }

parse_flags() {
    for arg in "$@"; do
        case $arg in
            -y | --yes) ASSUME_YES=1 ;;
            -n | --dry-run) DRY_RUN=1 ;;
            -h | --help) usage; exit 0 ;;
            *) die "unknown option: $arg (try --help)" ;;
        esac
    done
}

# ask "question?" -- succeeds on yes. Never guesses: with no terminal, the answer is no.
ask() {
    [ "$ASSUME_YES" = 1 ] && return 0
    [ -t 0 ] || return 1
    printf '%s [y/N] ' "$1"
    read -r reply
    case $reply in y | Y | yes | YES) return 0 ;; *) return 1 ;; esac
}

# choose "item item" -- show the plan, then set CHOSEN to what the person agrees to.
choose() {
    CHOSEN=''
    [ -n "$1" ] || { say '  nothing to install'; return 0; }
    say 'Will install:'
    for item in $1; do say "  - $item: $(describe "$item")"; done
    [ "$DRY_RUN" = 1 ] && { say '  (dry run: nothing is changed)'; return 0; }
    [ "$ASSUME_YES" = 1 ] && { CHOSEN=$1; return 0; }
    [ -t 0 ] || { warn 'no terminal; run again with -y to install'; return 0; }
    printf 'Install [a]ll, choose [o]ne by one, or [n]one? [a/o/N] '
    read -r reply
    case $reply in
        a | A) CHOSEN=$1 ;;
        o | O) for item in $1; do ask "  install $item?" && CHOSEN="$CHOSEN $item"; done ;;
    esac
}

# fetch URL [FILE] -- print the page, or save it to FILE.
fetch() {
    if has curl; then
        if [ -n "${2:-}" ]; then curl -fsSL -o "$2" "$1"; else curl -fsSL "$1"; fi
    elif has wget; then
        if [ -n "${2:-}" ]; then wget -q -O "$2" "$1"; else wget -q -O - "$1"; fi
    else
        die 'curl or wget is required'
    fi
}

# release_url OWNER/REPO REGEX -- the first asset of the latest release matching REGEX.
# Asset names carry version numbers, so they are matched, never spelled out.
release_url() {
    fetch "https://api.github.com/repos/$1/releases/latest" |
        grep -o '"browser_download_url": *"[^"]*"' |
        sed 's/.*"\(https[^"]*\)"$/\1/' |
        grep -E "$2" | head -n 1
}

# install_from OWNER/REPO REGEX BINARY -- put one binary from a release into ~/.local/bin.
install_from() {
    url=$(release_url "$1" "$2")
    [ -n "$url" ] || { warn "no asset matching '$2' in $1 (or GitHub's rate limit was hit)"; return 1; }
    tmp=$(mktemp -d) || return 1
    fetch "$url" "$tmp/download" || { rm -rf "$tmp"; return 1; }
    case $url in
        *.tar.gz) tar -xzf "$tmp/download" -C "$tmp" ;;
        *.gz) gzip -dc "$tmp/download" >"$tmp/$3" ;;
    esac
    found=$(find "$tmp" -type f -name "$3" | head -n 1)
    [ -n "$found" ] || { warn "$3 not found inside $url"; rm -rf "$tmp"; return 1; }
    mkdir -p "$BIN" && cp "$found" "$BIN/$3" && chmod +x "$BIN/$3"
    rm -rf "$tmp"
}

# install_tree URL NAME RELATIVE_BINARY -- unpack a whole release into
# ~/.local/share/NAME and link its binary into ~/.local/bin (for tools that need their files).
install_tree() {
    tmp=$(mktemp -d) || return 1
    fetch "$1" "$tmp/download" || { rm -rf "$tmp"; return 1; }
    case $1 in
        *.tar.gz) tar -xzf "$tmp/download" -C "$tmp" ;;
        *.zip) unzip -q "$tmp/download" -d "$tmp" ;;
    esac
    rm "$tmp/download"
    top=$(ls "$tmp" | head -n 1)
    [ -x "$tmp/$top/$3" ] || { warn "unexpected archive layout in $1"; rm -rf "$tmp"; return 1; }
    rm -rf "${SHARE:?}/$2"
    mkdir -p "$SHARE" "$BIN"
    mv "$tmp/$top" "$SHARE/$2"
    ln -sf "$SHARE/$2/$3" "$BIN/$(basename "$3")"
    rm -rf "$tmp"
    if [ "$OS" = macos ]; then xattr -cr "$SHARE/$2" 2>/dev/null || true; fi
}
