-- 42 school: file header, formatter, Norminette.
-- The formatter and linter are external 42 programs (sh/lang/c.sh installs them);
-- this file only runs them on the current file.

---The current file's path, or nil with an explanation.
local function file_for(command)
    local file = vim.api.nvim_buf_get_name(0)
    if file == '' then
        vim.notify('No file name yet', vim.log.levels.WARN)
        return nil
    end
    if vim.fn.executable(command) ~= 1 then
        vim.notify(command .. ' is not installed; run sh/lang/c.sh', vim.log.levels.WARN)
        return nil
    end
    return file
end

-- c_formatter_42 takes a path and rewrites it, so the buffer is saved first
-- and reloaded after.
local function format42()
    local file = file_for('c_formatter_42')
    if not file then
        return
    end
    vim.cmd.write()
    local result = vim.system({ 'c_formatter_42', file }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify(vim.trim(result.stderr or '42 formatting failed'), vim.log.levels.ERROR)
        return
    end
    vim.cmd.checktime()
    vim.notify('42 formatting complete')
end

-- Norminette prints problems on stdout and failures on stderr; show both.
local function norminette()
    local file = file_for('norminette')
    if not file then
        return
    end
    local result = vim.system({ 'norminette', file }, { text = true }):wait()
    local output = vim.trim((result.stdout or '') .. (result.stderr or ''))
    vim.notify(
        output ~= '' and output or 'Norminette found nothing to complain about',
        result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
    )
end

return {
    'Diogo-ss/42-header.nvim',
    'hardyrafael17/norminette42.nvim',
    config = function()
        require('42header').setup({
            default_map = false,
            -- The header follows the filename, so renaming a file fixes it.
            auto_update = true,
            user = 'abait-el',
            mail = 'abait-el@student.1337.ma',
        })
        require('norminette').setup({
            -- Never on save: it is noise while you are mid-edit. <leader>4n asks.
            runOnSave = false,
            maxErrorsToShow = 5,
            active = vim.fn.executable('norminette') == 1,
        })

        vim.api.nvim_create_user_command('Format42', format42, { desc = 'Format the file to the 42 norm' })
        vim.api.nvim_create_user_command('Check42', norminette, { desc = 'Run Norminette on the file' })
        vim.keymap.set('n', '<leader>4h', '<cmd>Stdheader<cr>', { desc = 'Insert the 42 header' })
        vim.keymap.set('n', '<leader>4f', '<cmd>Format42<cr>', { desc = 'Format to the 42 norm' })
        vim.keymap.set('n', '<leader>4n', '<cmd>Check42<cr>', { desc = 'Run Norminette' })
    end,
}
