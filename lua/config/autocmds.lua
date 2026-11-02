-- Automatic behavior. Each block says what would go wrong without it.
local api = vim.api

local function group(name)
    return api.nvim_create_augroup('config_' .. name, { clear = true })
end

api.nvim_create_autocmd('TextYankPost', {
    group = group('yank'),
    desc = 'Flash yanked text, so you see what you grabbed',
    callback = function()
        vim.hl.on_yank({ timeout = 150 })
    end,
})

api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = group('checktime'),
    desc = 'Reload files changed outside Neovim',
    callback = function()
        if vim.bo.buftype ~= 'nofile' then
            vim.cmd.checktime()
        end
    end,
})

api.nvim_create_autocmd('BufWritePre', {
    group = group('mkdir'),
    desc = 'Create missing parent directories on write',
    callback = function(args)
        if not args.match:match('^%w%w+://') then
            vim.fn.mkdir(vim.fn.fnamemodify(args.match, ':p:h'), 'p')
        end
    end,
})

api.nvim_create_autocmd('BufReadPost', {
    group = group('last_position'),
    desc = 'Return to the last cursor position',
    callback = function(args)
        if vim.bo[args.buf].buftype ~= '' then
            return
        end
        local mark = api.nvim_buf_get_mark(args.buf, '"')
        if mark[1] > 0 and mark[1] <= api.nvim_buf_line_count(args.buf) then
            pcall(api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

api.nvim_create_autocmd('FileType', {
    group = group('close_with_q'),
    pattern = { 'checkhealth', 'help', 'qf', 'startuptime' },
    desc = 'Info windows are unlisted and close with q',
    callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = args.buf, silent = true })
    end,
})

api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
    group = group('terminal'),
    desc = 'Strip editor chrome from terminals and start typing',
    callback = function(args)
        if vim.bo[args.buf].buftype ~= 'terminal' then
            return
        end
        vim.bo[args.buf].buflisted = false
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = 'no'
        vim.cmd.startinsert()
    end,
})

-- Per-filetype editing: { shiftwidth, expandtab, colorcolumn, wrap, spell }.
-- The colorcolumn marks the limit the formatter enforces (42 caps C at 80).
local filetypes = {
    c = { 4, false, '80' },
    cpp = { 4, false, '100' },
    python = { 4, true, '79' },
    go = { 4, false, '100' },
    lua = { 4, true, '120' },
    sh = { 4, true, '100' },
    make = { 8, false, '100' },
    json = { 2, true, '100' },
    yaml = { 2, true, '100' },
    toml = { 2, true, '100' },
    markdown = { 2, true, '100', true, true },
}

api.nvim_create_autocmd('FileType', {
    group = group('filetype_options'),
    pattern = vim.tbl_keys(filetypes),
    desc = 'Apply per-filetype editing options',
    callback = function(args)
        local width, expand, column, wrap, spell = unpack(filetypes[args.match])
        vim.bo[args.buf].shiftwidth = width
        vim.bo[args.buf].tabstop = width
        vim.bo[args.buf].softtabstop = width
        vim.bo[args.buf].expandtab = expand
        vim.wo.colorcolumn = column
        if wrap ~= nil then
            vim.wo.wrap = wrap
            vim.wo.spell = spell
        end
    end,
})
