-- Ctrl-h/j/k/l move between Neovim splits and tmux panes as one grid.
-- The globals are set at load time, before the plugin reads them.
vim.g.tmux_navigator_no_mappings = 1
vim.g.tmux_navigator_preserve_zoom = 1

return {
    'christoomey/vim-tmux-navigator',
    config = function()
        vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { silent = true, desc = 'Focus left' })
        vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { silent = true, desc = 'Focus down' })
        vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { silent = true, desc = 'Focus up' })
        vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = 'Focus right' })
    end,
}
