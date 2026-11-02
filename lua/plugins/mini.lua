-- mini.nvim: one plugin, five small tools. Only these modules are used.
-- Commenting is built into Neovim (gc, gcc), so there is no comment plugin.
return {
    'nvim-mini/mini.nvim',
    config = function()
        -- Text objects: va) vi" vaf and so on, across up to 300 lines.
        require('mini.ai').setup({ n_lines = 300 })

        require('mini.pairs').setup()

        -- vim-surround keys, because flash.lua owns `s`.
        require('mini.surround').setup({
            mappings = {
                add = 'ys',
                delete = 'ds',
                replace = 'cs',
                find = 'gsf',
                find_left = 'gsF',
                highlight = 'gsh',
                suffix_last = 'l',
                suffix_next = 'n',
            },
            search_method = 'cover_or_next',
        })
        vim.keymap.set('n', 'yss', 'ys_', { remap = true, desc = 'Surround the line' })

        -- File and LSP-kind glyphs for oil, snacks and completion.
        local icons = require('mini.icons')
        icons.setup()
        icons.mock_nvim_web_devicons()
        icons.tweak_lsp_kind()

        -- Pause after <leader> (or g, z, [, ]) and see the keys that follow.
        local clue = require('mini.clue')
        clue.setup({
            triggers = {
                { mode = 'n', keys = '<Leader>' },
                { mode = 'x', keys = '<Leader>' },
                { mode = 'n', keys = 'g' },
                { mode = 'n', keys = 'z' },
                { mode = 'n', keys = '[' },
                { mode = 'n', keys = ']' },
            },
            clues = {
                -- Names for the <leader> groups. Add one when you add a group.
                { mode = 'n', keys = '<Leader>4', desc = '+42 school' },
                { mode = 'n', keys = '<Leader>a', desc = '+whole buffer' },
                { mode = 'n', keys = '<Leader>b', desc = '+buffers' },
                { mode = 'n', keys = '<Leader>c', desc = '+code' },
                { mode = 'n', keys = '<Leader>f', desc = '+find/files' },
                { mode = 'n', keys = '<Leader>g', desc = '+git' },
                { mode = 'n', keys = '<Leader>q', desc = '+problems' },
                { mode = 'n', keys = '<Leader>t', desc = '+toggles' },
                { mode = 'n', keys = '<Leader>u', desc = '+undo' },
                { mode = 'n', keys = '<Leader>w', desc = '+windows' },
                { mode = 'n', keys = '<Leader>x', desc = '+terminal' },
                clue.gen_clues.g(),
                clue.gen_clues.z(),
                clue.gen_clues.marks(),
                clue.gen_clues.registers(),
                clue.gen_clues.windows(),
            },
            window = { delay = 250 },
        })
    end,
}
