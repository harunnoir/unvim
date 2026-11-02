-- Completion. Neovim 0.12 has a native `autocomplete` option; blink adds fuzzy
-- matching, snippets and documentation. To go without a plugin, delete this file.
return {
    { src = 'saghen/blink.cmp', version = vim.version.range('1.*') },
    'rafamadriz/friendly-snippets',
    config = function()
        require('blink.cmp').setup({
            -- `<leader>ta` flips vim.g.assist; nil means on.
            enabled = function()
                return vim.g.assist ~= false and vim.bo.buftype ~= 'prompt'
            end,
            keymap = { preset = 'default' },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 250 },
                ghost_text = { enabled = true },
            },
            signature = { enabled = true },
            sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
            -- Use the fast Rust matcher when its prebuilt binary downloads,
            -- otherwise fall back to Lua quietly.
            fuzzy = { implementation = 'prefer_rust' },
        })
    end,
}
