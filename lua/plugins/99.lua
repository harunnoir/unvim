-- 99: AI-assisted code search and editing.
return {
    'ThePrimeagen/99',
    config = function()
        local _99 = require('99')
        local AgyProvider = require('config.providers.agy')

        _99.setup({
            provider = AgyProvider,
        })

        vim.keymap.set('n', '<leader>9s', function()
            _99.search()
        end, { desc = 'AI search' })

        vim.keymap.set('v', '<leader>9v', function()
            _99.visual()
        end, { desc = 'AI edit selection' })

        vim.keymap.set('n', '<leader>9x', function()
            _99.stop_all_requests()
        end, { desc = 'Stop AI requests' })

        vim.keymap.set('n', '<leader>9o', function()
            _99.open()
        end, { desc = 'Open AI results' })
    end,
}
