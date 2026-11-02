-- Highlights TODO/FIX/HACK in comments and jumps between them.
return {
    'nvim-lua/plenary.nvim',
    'folke/todo-comments.nvim',
    config = function()
        require('todo-comments').setup({ highlight = { comments_only = true } })
        vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'Next TODO' })
        vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'Previous TODO' })
    end,
}
