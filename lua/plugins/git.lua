-- Git in the buffer: signs in the gutter and hunk actions. Lazygit is in picker.lua.
return {
    'lewis6991/gitsigns.nvim',
    config = function()
        require('gitsigns').setup({
            signs = {
                add = { text = '┃' },
                change = { text = '┃' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
                untracked = { text = '┆' },
            },
            on_attach = function(buf)
                local gs = require('gitsigns')
                local function map(modes, lhs, rhs, desc)
                    vim.keymap.set(modes, lhs, rhs, { buffer = buf, silent = true, desc = desc })
                end
                map('n', ']h', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ args = { ']c' }, bang = true })
                    else
                        gs.nav_hunk('next')
                    end
                end, 'Next hunk')
                map('n', '[h', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ args = { '[c' }, bang = true })
                    else
                        gs.nav_hunk('prev')
                    end
                end, 'Previous hunk')
                map('n', '<leader>gh', gs.preview_hunk, 'Preview hunk')
                -- stage_hunk toggles: run it on a staged hunk to unstage it.
                map({ 'n', 'x' }, '<leader>ga', gs.stage_hunk, 'Stage or unstage hunk')
                map({ 'n', 'x' }, '<leader>gr', gs.reset_hunk, 'Reset hunk')
                map('n', '<leader>gB', gs.blame_line, 'Blame line')
            end,
        })
    end,
}
