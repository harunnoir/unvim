-- Project-wide search and replace with a live preview.
return {
    'MagicDuck/grug-far.nvim',
    config = function()
        require('grug-far').setup()
        vim.keymap.set('n', '<leader>fR', '<cmd>GrugFar<cr>', { desc = 'Find and replace' })
    end,
}
