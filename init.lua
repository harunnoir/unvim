-- Entry point: a table of contents. Edit the files it names, not this one.
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

if vim.fn.has('nvim-0.12') ~= 1 then
    vim.notify('This config needs Neovim 0.12+. Run sh/install.sh', vim.log.levels.ERROR)
    return
end

require('config.options')
require('config.autocmds')
require('config.plugins') -- installs and loads every file in lua/plugins/
require('config.lsp')
require('config.keymaps') -- last, so it wins any conflict
