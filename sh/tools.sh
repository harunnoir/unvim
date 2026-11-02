# tools.sh -- how each tool is described, detected and installed, without root.
# For a tool NAME there are three entries: describe, installed, and install_NAME.
# A name uses underscores where its command uses dashes (tree_sitter -> tree-sitter).
# Needs lib.sh sourced first.

rust_cpu() { if [ "$CPU" = arm64 ]; then echo aarch64; else echo x86_64; fi; }

# True when Neovim exists and is 0.12 or newer.
nvim_ok() {
    has nvim || return 1
    set -- $(nvim --version | sed -n '1s/^NVIM v\([0-9]*\)\.\([0-9]*\).*/\1 \2/p')
    [ "${1:-0}" -gt 0 ] || [ "${2:-0}" -ge 12 ]
}

describe() {
    case $1 in
        nvim)
            if has nvim; then
                echo "a newer Neovim into ~/.local/share/neovim (you have $(nvim --version | head -n 1); it stays untouched)"
            else
                echo 'Neovim, official release into ~/.local/share/neovim'
            fi ;;
        rg) echo 'ripgrep, the search behind the picker (release binary into ~/.local/bin)' ;;
        fd) echo 'fd, the file finder behind the picker (release binary)' ;;
        lazygit) echo 'lazygit, git UI inside Neovim (release binary, optional)' ;;
        tree_sitter) echo 'tree-sitter CLI, builds syntax parsers (release binary)' ;;
        uv) echo 'uv, installs Python tools into ~/.local/bin (release binary)' ;;
        clangd) echo 'clangd, C/C++ language server (release into ~/.local/share/clangd)' ;;
        basedpyright) echo 'basedpyright, Python language server (via uv)' ;;
        flake8) echo 'flake8, Python linter (via uv)' ;;
        autopep8) echo 'autopep8, Python formatter (via uv)' ;;
        docformatter) echo 'docformatter, Python docstring formatter (via uv)' ;;
        norminette) echo 'norminette, the 42 style checker (via uv)' ;;
        c_formatter_42) echo 'c_formatter_42, the 42 C formatter (via uv)' ;;
        gopls) echo 'gopls, Go language server (go install)' ;;
        gofumpt) echo 'gofumpt, Go formatter (go install)' ;;
        parser_*) echo "Tree-sitter parser '${1#parser_}', compiled locally" ;;
        *) echo "$1" ;;
    esac
}

installed() {
    case $1 in
        nvim) nvim_ok ;;
        tree_sitter) has tree-sitter ;;
        basedpyright) has basedpyright-langserver ;;
        parser_*) [ -f "$SHARE/nvim/site/parser/${1#parser_}.so" ] ;;
        *) has "$1" ;;
    esac
}

# missing NAME... -- the names that are not installed yet.
missing() {
    list=''
    for tool in "$@"; do installed "$tool" || list="$list $tool"; done
    echo $list
}

# install_chosen -- install every name in CHOSEN, one at a time.
install_chosen() {
    for item in $CHOSEN; do
        say "==> $item"
        case $item in
            parser_*) install_parser "${item#parser_}" ;;
            *) "install_$item" ;;
        esac || warn "$item was not installed"
    done
}

# --- Neovim and the tools it leans on ---------------------------------------

install_nvim() {
    case $OS-$CPU in
        linux-x86_64) asset=nvim-linux-x86_64 ;;
        linux-arm64) asset=nvim-linux-arm64 ;;
        macos-x86_64) asset=nvim-macos-x86_64 ;;
        macos-arm64) asset=nvim-macos-arm64 ;;
    esac
    # NVIM_VERSION=v0.12.0 pins a release; the default is the latest stable one.
    if [ "${NVIM_VERSION:-latest}" = latest ]; then
        url="https://github.com/neovim/neovim/releases/latest/download/$asset.tar.gz"
    else
        url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$asset.tar.gz"
    fi
    install_tree "$url" neovim bin/nvim
}

install_rg() {
    if [ "$OS" = linux ]; then re="$(rust_cpu)"'-unknown-linux-(musl|gnu)\.tar\.gz$'; else re="$(rust_cpu)"'-apple-darwin\.tar\.gz$'; fi
    install_from BurntSushi/ripgrep "$re" rg
}

install_fd() {
    if [ "$OS" = linux ]; then re="$(rust_cpu)"'-unknown-linux-(musl|gnu)\.tar\.gz$'; else re="$(rust_cpu)"'-apple-darwin\.tar\.gz$'; fi
    install_from sharkdp/fd "$re" fd
}

install_lazygit() {
    if [ "$OS" = linux ]; then name=Linux; else name=Darwin; fi
    install_from jesseduffield/lazygit "_${name}_${CPU}"'\.tar\.gz$' lazygit
}

install_tree_sitter() {
    if [ "$OS" = linux ]; then name=linux; else name=macos; fi
    if [ "$CPU" = arm64 ]; then arch=arm64; else arch=x64; fi
    install_from tree-sitter/tree-sitter "tree-sitter-$name-$arch"'\.gz$' tree-sitter
}

install_uv() {
    if [ "$OS" = linux ]; then re="uv-$(rust_cpu)"'-unknown-linux-(gnu|musl)\.tar\.gz$'; else re="uv-$(rust_cpu)"'-apple-darwin\.tar\.gz$'; fi
    install_from astral-sh/uv "$re" uv
}

# --- Language tools ----------------------------------------------------------

install_clangd() {
    has unzip || { warn 'unzip is needed to unpack clangd'; return 1; }
    if [ "$OS" = linux ]; then
        [ "$CPU" = x86_64 ] || { warn 'clangd publishes no arm64 Linux build; install it with your package manager'; return 1; }
        re='clangd-linux-[0-9.]+\.zip$'
    else
        re='clangd-mac-[0-9.]+\.zip$'
    fi
    url=$(release_url clangd/clangd "$re")
    [ -n "$url" ] || { warn 'no clangd release asset found'; return 1; }
    install_tree "$url" clangd bin/clangd
}

# uv_tool COMMAND PACKAGE -- a Python tool in ~/.local/bin, isolated from every project.
uv_tool() {
    has uv || { warn 'uv is required first'; return 1; }
    UV_TOOL_BIN_DIR="$BIN" uv tool install --force "$2" && has "$1"
}
install_basedpyright() { uv_tool basedpyright-langserver basedpyright; }
install_flake8() { uv_tool flake8 flake8; }
install_autopep8() { uv_tool autopep8 autopep8; }
install_docformatter() { uv_tool docformatter docformatter; }
install_norminette() { uv_tool norminette norminette; }
install_c_formatter_42() { uv_tool c_formatter_42 c-formatter-42; }

go_tool() {
    has go || { warn 'Go is required first'; return 1; }
    go install "$1"
}
install_gopls() { go_tool golang.org/x/tools/gopls@latest; }
install_gofumpt() { go_tool mvdan.cc/gofumpt@latest; }

# install_parser LANGUAGE -- ask Neovim's nvim-treesitter to build a parser.
install_parser() {
    has nvim || { warn 'Neovim is needed to build parsers'; return 1; }
    has tree-sitter || { warn 'the tree-sitter CLI is needed; run sh/install.sh first'; return 1; }
    has cc || has gcc || has clang || { warn 'a C compiler is needed to build parsers'; return 1; }
    NVIM_INSTALL=1 nvim --headless "+lua require('nvim-treesitter').install({ '$1' }):wait(300000)" +qa
}
