-- Formatting, on demand with <leader>cf. Nothing reformats when you save.
-- Formatters are external programs; sh/lang/*.sh installs them.
return {
    'stevearc/conform.nvim',
    config = function()
        require('conform').setup({
            default_format_opts = { lsp_format = 'fallback' },
            formatters_by_ft = {
                -- Run in order: docstrings are rewrapped after autopep8 touches code.
                python = { 'autopep8', 'docformatter' },
                c = { 'c_formatter_42' },
                cpp = { 'c_formatter_42' },
                go = { 'gofumpt' },
            },
            formatters = {
                autopep8 = { prepend_args = { '--max-line-length', '79' } },
                c_formatter_42 = { command = 'c_formatter_42', args = {}, stdin = true },
                -- The trailing `-` makes docformatter read stdin; without it
                -- it rewrites the file in place and breaks chaining.
                docformatter = {
                    args = { '--wrap-summaries', '79', '--wrap-descriptions', '79', '-' },
                    stdin = true,
                },
            },
        })

        vim.keymap.set({ 'n', 'x' }, '<leader>cf', function()
            require('conform').format({ async = true })
        end, { desc = 'Format buffer or selection' })
    end,
}
