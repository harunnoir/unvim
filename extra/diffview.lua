-- Side-by-side diffs and per-file history.
return {
    'sindrets/diffview.nvim',
    config = function()
        vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Open the diff view' })
        vim.keymap.set('n', '<leader>gD', '<cmd>DiffviewFileHistory %<cr>', { desc = 'History of this file' })
        vim.keymap.set('n', '<leader>gv', '<cmd>DiffviewClose<cr>', { desc = 'Close the diff view' })
    end,
}
