## Plugin Loader

- [ ] Support grouped plugin specifications in `lua/config/plugins.lua`.
  - [ ] Allow multiple plugin specifications to be grouped in a single table.
  - [ ] Preserve support for flat plugin specifications.
  - [ ] Support mixing grouped and flat specifications.
  - [ ] Support per-plugin `config` functions.
  - [ ] Flatten plugin groups before passing specifications to `vim.pack`.
  - [ ] Keep file-level configuration separate from per-plugin configuration.
  - [ ] Validate plugin specifications and report malformed entries clearly.
  - [ ] Add tests for flat, grouped, and mixed specifications.

## Runtime Structure

- [ ] Introduce Neovim's native `after/` directory for configuration overrides.
  - [ ] Add `after/ftplugin/` for filetype-specific settings.
  - [ ] Move appropriate filetype-specific settings out of general configuration files.
  - [ ] Keep filetype settings local using `vim.opt_local`.
  - [ ] Add `after/queries/` only when custom Tree-sitter queries are needed.
  - [ ] Keep plugin specifications and general configuration under `lua/`.
  - [ ] Document the purpose and conventions of `after/` in README.md.
