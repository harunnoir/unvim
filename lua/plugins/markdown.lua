-- Markdown rendering. Keep the source readable while rendering headings,
-- code blocks, tables and checkboxes inline. Delete this file to go without it.
return {
    { src = 'MeanderingProgrammer/render-markdown.nvim' },
    config = function()
        require('render-markdown').setup({})

        vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', {
            desc = 'Toggle Markdown rendering',
        })
    end,
}
