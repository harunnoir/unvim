# nvim

A small Neovim 0.12+ config. One file per feature, plain tables, nothing generated.
Neovim's own `vim.pack` fetches plugins and pins them in `nvim-pack-lock.json`.

## Install

    sh/install.sh          # Neovim 0.12+, core tools, plugins (asks first, no root)
    sh/lang/c.sh           # C and C++  (clangd, 42 formatter, Norminette)
    sh/lang/python.sh      # Python     (basedpyright, flake8, autopep8, docformatter)
    sh/lang/go.sh          # Go         (gopls, gofumpt)
    sh/doctor.sh           # what is installed, what is missing

Every script takes `-n` (show the plan only) and `-y` (do not ask).
Everything lands in `~/.local` (or `~/go/bin`); `sudo` is never used.
Tools that need your package manager (git, a C compiler) are only checked.

## Layout

    init.lua               table of contents
    lua/config/            options, autocmds, keymaps, lsp, and the plugin loader
    lua/plugins/           one file per feature; every file here is loaded
    extra/                 optional plugins, not loaded; move one into lua/plugins/
    sh/                    installers; sh/lang/ has one script per language
    spell/                 your spelling dictionary

## Everyday edits

| To...                    | Do this                                                         |
|--------------------------|-----------------------------------------------------------------|
| add a plugin             | create `lua/plugins/<name>.lua` (copy any file there) and restart |
| remove a plugin          | delete its file, then `:lua vim.pack.del({ 'name' })`           |
| update plugins           | `:lua vim.pack.update()`, review, confirm; commit the lockfile  |
| add a language server    | add an entry to `lua/config/lsp.lua`                            |
| add a formatter / linter | `lua/plugins/format.lua` / `lua/plugins/lint.lua`               |
| add a language installer | copy `sh/lang/go.sh`, add its tools to `sh/tools.sh`            |
| add a leader group name  | the `clues` list in `lua/plugins/mini.lua`                      |

Plugins never update by themselves, so nothing changes until you ask.

## Keys

`<Space>` is the leader; pause after it for the list. Groups: `a` whole buffer,
`b` buffers, `c` code, `f` find, `g` git, `q` problems, `t` toggles, `w` windows,
`x` terminal, `4` 42 school, `u` undo. `<leader>ta` switches diagnostics and
completion off and on together. Neovim's own LSP keys still work (`grn`, `gra`,
`grr`, `K`, `gO`).

## Rules this config follows

- A file does one thing; a plugin's keys live in its own file.
- Prefer what Neovim ships (commenting, LSP defaults, folds, statusline) to a plugin.
- External tools do the work (rg, fd, formatters, linters); Neovim only calls them.
- A missing tool means that feature is off, never an error on every keystroke.
- Format with `stylua .` (settings in `.stylua.toml`).
