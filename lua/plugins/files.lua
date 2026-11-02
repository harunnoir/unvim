-- File explorer: edit a directory like a buffer, save to apply the changes.
return {
    'stevearc/oil.nvim',
    config = function()
        require('oil').setup({
            default_file_explorer = true,
            -- Recoverable deletes, but only when trash-put exists.
            delete_to_trash = vim.fn.executable('trash-put') == 1,
            columns = { 'icon', 'permissions', 'size', 'mtime' },
            view_options = { show_hidden = false, natural_order = true },
            float = { max_width = 100, max_height = 35 },
        })
        vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open the parent directory' })
        vim.keymap.set('n', '<leader>fe', '<cmd>Oil<cr>', { desc = 'File explorer' })
    end,
}
