
-- Automatic behavior. Each block says what would go wrong without it.
local api = vim.api

local function group(name)
    return api.nvim_create_augroup('config_' .. name, { clear = true })
end

-- Show which text was yanked.
api.nvim_create_autocmd('TextYankPost', {
    group = group('yank'),
    desc = 'Flash yanked text',
    callback = function()
        vim.hl.on_yank({ timeout = 150 })
    end,
})

-- Reload files changed outside Neovim.
api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = group('checktime'),
    desc = 'Reload files changed outside Neovim',
    callback = function()
        if vim.bo.buftype ~= 'nofile' then
            vim.cmd.checktime()
        end
    end,
})

-- Create missing parent directories before writing.
api.nvim_create_autocmd('BufWritePre', {
    group = group('mkdir'),
    desc = 'Create missing parent directories on write',
    callback = function(args)
        if not args.match:match('^%w%w+://') then
            local dir = vim.fn.fnamemodify(args.file, ':p:h')
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

-- Restore the last cursor position when reopening a file.
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

-- Make informational windows easy to close.
api.nvim_create_autocmd('FileType', {
    group = group('close_with_q'),
    pattern = { 'checkhealth', 'help', 'qf', 'startuptime' },
    desc = 'Make informational windows unlisted and closeable with q',
    callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>close<cr>', {
            buffer = args.buf,
            silent = true,
            desc = 'Close window',
        })
    end,
})

-- Strip editor chrome from terminal windows.
api.nvim_create_autocmd({ 'TermOpen', 'BufEnter' }, {
    group = group('terminal'),
    desc = 'Strip editor chrome from terminals',
    callback = function(args)
        if vim.bo[args.buf].buftype ~= 'terminal' then
            return
        end

        vim.bo[args.buf].buflisted = false

        local win = api.nvim_get_current_win()
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        vim.wo[win].signcolumn = 'no'

        if args.event == 'TermOpen' then
            vim.cmd.startinsert()
        end
    end,
})
