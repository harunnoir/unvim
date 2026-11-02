-- Syntax tree: highlighting, and text objects by function/class.
-- Parsers are compiled locally; sh/lang/*.sh installs the ones a language needs.
-- Neovim bundles c, lua, vim, vimdoc, query and markdown already.

-- Registered at load time, before vim.pack runs, so it sees the first install.
vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('config_treesitter_build', { clear = true }),
    desc = 'Update parsers when nvim-treesitter changes',
    callback = function(event)
        local data = event.data
        if data.spec.name == 'nvim-treesitter' and (data.kind == 'install' or data.kind == 'update') then
            if not data.active then
                vim.cmd.packadd('nvim-treesitter')
            end
            pcall(vim.cmd, 'TSUpdate')
        end
    end,
})

return {
    { src = 'nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
    config = function()
        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('config_treesitter_start', { clear = true }),
            desc = 'Start the parser for this filetype, if there is one',
            callback = function(args)
                pcall(vim.treesitter.start, args.buf)
            end,
        })

        require('nvim-treesitter-textobjects').setup({
            select = { lookahead = true },
            move = { set_jumps = true },
        })

        local select = require('nvim-treesitter-textobjects.select')
        local move = require('nvim-treesitter-textobjects.move')
        local function pick(lhs, query, desc)
            vim.keymap.set({ 'x', 'o' }, lhs, function()
                select.select_textobject(query, 'textobjects')
            end, { desc = desc })
        end
        pick('af', '@function.outer', 'Around function')
        pick('if', '@function.inner', 'Inside function')
        pick('ac', '@class.outer', 'Around class')
        pick('ic', '@class.inner', 'Inside class')
        vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
            move.goto_next_start('@function.outer', 'textobjects')
        end, { desc = 'Next function' })
        vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
            move.goto_previous_start('@function.outer', 'textobjects')
        end, { desc = 'Previous function' })
    end,
}
