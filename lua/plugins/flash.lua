-- Jump anywhere on screen: `s` then two letters. `S` picks a syntax node.
return {
    'folke/flash.nvim',
    config = function()
        require('flash').setup()
        vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
        vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash syntax node' })
        vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Flash remote' })
    end,
}
