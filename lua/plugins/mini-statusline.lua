-- Statusline: minimal and informative.
return {
    'nvim-mini/mini.statusline',
    config = function()
        require('mini.statusline').setup({
            use_icons = false,
        })
    end,
}
