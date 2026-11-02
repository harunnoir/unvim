-- Colorscheme. To try another, add its repo here and run :colorscheme <name>.
return {
    'sainnhe/gruvbox-material',
    config = function()
        vim.g.gruvbox_material_background = 'soft'
        vim.g.gruvbox_material_foreground = 'material'
        vim.g.gruvbox_material_enable_italic = 1
        vim.g.gruvbox_material_ui_contrast = 'low'
        vim.g.gruvbox_material_float_style = 'dim'
        vim.g.gruvbox_material_show_eob = 0
        vim.g.gruvbox_material_diagnostic_text_highlight = 1
        vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
        vim.g.gruvbox_material_better_performance = 1
        vim.cmd.colorscheme('gruvbox-material')
    end,
}
