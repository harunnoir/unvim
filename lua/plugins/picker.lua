-- Snacks: the fuzzy picker, lazygit, terminals, notifications.
-- Only the pieces used are switched on; Snacks has many more.
return {
    'folke/snacks.nvim',
    config = function()
        require('snacks').setup({
            bigfile = { enabled = true },
            quickfile = { enabled = true },
            input = { enabled = true },
            notifier = { enabled = true, timeout = 2500 },
            bufdelete = { enabled = true },
            terminal = {
                enabled = true,
                win = {
                    position = 'bottom',
                    height = 0.35,
                    style = 'terminal',
                },
            },
            lazygit = { enabled = true },
            gitbrowse = { enabled = true },
            statuscolumn = {
                enabled = true,
            },
            indent = { enabled = true },
            scope = { enabled = true },
            words = { enabled = true },
            scratch = { enabled = true },
            explorer = {
                enabled = false,
                replace_netrw = false,
            },
            -- ui_select makes vim.ui.select use the same picker.
            picker = { enabled = true, ui_select = true, layout = { preset = 'ivy', cycle = true } },
        })

        local function map(modes, lhs, rhs, desc)
            vim.keymap.set(modes, lhs, rhs, { silent = true, desc = desc })
        end

        -- Find.
        map('n', '<leader>ff', function() Snacks.picker.files() end, 'Find files')
        map('n', '<leader>fg', function() Snacks.picker.grep() end, 'Grep the project')
        map({ 'n', 'x' }, '<leader>fw', function() Snacks.picker.grep_word() end, 'Grep the word under the cursor')
        map('n', '<leader>fr', function() Snacks.picker.recent() end, 'Recent files')
        map('n', '<leader>fh', function() Snacks.picker.help() end, 'Help tags')
        map('n', '<leader>fk', function() Snacks.picker.keymaps() end, 'Keymaps')
        map('n', '<leader>fc', function()
            Snacks.picker.files({ cwd = vim.fn.stdpath('config'), title = 'Config files' })
        end, 'Config files')
        map('n', '<leader>ft', function()
            Snacks.picker.grep({ search = 'TODO|FIXME|HACK' })
        end, 'TODO comments')

        -- Buffers.
        map('n', '<leader>bb', function() Snacks.picker.buffers() end, 'Buffers')
        map('n', '<leader>bd', function() Snacks.bufdelete() end, 'Delete buffer')
        map('n', '<leader>bo', function() Snacks.bufdelete.other() end, 'Delete other buffers')

        -- Git.
        map('n', '<leader>gg', function() Snacks.lazygit() end, 'Lazygit')
        map({ 'n', 'x' }, '<leader>go', function() Snacks.gitbrowse() end, 'Open in the browser')
        map('n', '<leader>gl', function() Snacks.picker.git_log() end, 'Git log')
        map('n', '<leader>gs', function() Snacks.picker.git_status() end, 'Git status')
        map('n', '<leader>gb', function() Snacks.picker.git_branches() end, 'Git branches')

        -- Problems.
        map('n', '<leader>qq', function() Snacks.picker.diagnostics() end, 'Workspace diagnostics')
        map('n', '<leader>qb', function() Snacks.picker.diagnostics_buffer() end, 'Buffer diagnostics')
        map('n', '<leader>qs', function() Snacks.picker.lsp_symbols() end, 'Symbols in this file')
        map('n', '<leader>ql', function() Snacks.picker.lsp_workspace_symbols() end, 'Symbols in the workspace')
        map('n', '<leader>qf', function() Snacks.picker.qflist() end, 'Quickfix list')

        -- Persistent terminal with switchable layouts.
        require('config.terminal').setup()
    end,
}
