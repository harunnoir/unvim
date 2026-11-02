-- Linting. Runs on open, on save and on leaving insert mode, never per keystroke.
return {
    'mfussenegger/nvim-lint',
    config = function()
        local lint = require('lint')
        lint.linters_by_ft = {
            python = { 'flake8' },
        }

        vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
            group = vim.api.nvim_create_augroup('config_lint', { clear = true }),
            desc = 'Run the linters for this filetype',
            callback = function()
                lint.try_lint(nil, { ignore_errors = true })
            end,
        })
    end,
}
