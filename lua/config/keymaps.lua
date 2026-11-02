-- Keymaps that belong to no plugin. A plugin's own keys live in its file under
-- lua/plugins/. Groups: a all-buffer, b buffers, c code, f find, g git,
-- q problems, t toggles, w windows, x terminal, 4 42 school, u undo.
local function map(modes, lhs, rhs, desc, extra)
    vim.keymap.set(modes, lhs, rhs, vim.tbl_extend('force', { silent = true, desc = desc }, extra or {}))
end

map({ 'n', 'x' }, '<Space>', '<Nop>', 'Leader')
map('n', '<Esc>', '<cmd>nohlsearch<cr>', 'Clear search highlight')
map({ 'n', 'i', 'x' }, '<C-s>', '<cmd>write<cr>', 'Write file')
map('n', '<BS>', '<C-^>', 'Alternate buffer')
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", 'Down by screen line', { expr = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", 'Up by screen line', { expr = true })
map('x', '<', '<gv', 'Outdent and keep selection')
map('x', '>', '>gv', 'Indent and keep selection')
map('x', 'p', 'P', 'Paste without replacing the register')
map('n', ']e', '<cmd>move .+1<cr>==', 'Move line down')
map('n', '[e', '<cmd>move .-2<cr>==', 'Move line up')
map('x', ']e', ":move '>+1<cr>gv=gv", 'Move selection down')
map('x', '[e', ":move '<-2<cr>gv=gv", 'Move selection up')
map('t', '<Esc><Esc>', '<C-\\><C-n>', 'Leave terminal mode')

-- Whole buffer.
map('n', '<leader>aa', 'ggVG', 'Select the whole buffer')
map('n', '<leader>ay', '<cmd>%yank +<cr>', 'Copy the whole buffer')
map('n', '<leader>ax', '<cmd>%delete +<cr>', 'Cut the whole buffer')

-- Buffers (the picker and delete keys are in plugins/picker.lua).
map('n', '<leader>bn', '<cmd>bnext<cr>', 'Next buffer')
map('n', '<leader>bp', '<cmd>bprevious<cr>', 'Previous buffer')

-- Windows. Ctrl-h/j/k/l are owned by plugins/tmux.lua.
map('n', '<leader>wv', '<C-w>v', 'Split vertically')
map('n', '<leader>ws', '<C-w>s', 'Split horizontally')
map('n', '<leader>wc', '<C-w>c', 'Close window')
map('n', '<leader>we', '<C-w>=', 'Equalize windows')
map('n', '<leader>wo', '<C-w>o', 'Keep only this window')
map('n', '<A-h>', '<cmd>vertical resize -2<cr>', 'Narrower')
map('n', '<A-l>', '<cmd>vertical resize +2<cr>', 'Wider')
map('n', '<A-j>', '<cmd>resize +2<cr>', 'Taller')
map('n', '<A-k>', '<cmd>resize -2<cr>', 'Shorter')

-- Maximize is a tab holding the same buffer; closing the tab restores the layout.
map('n', '<leader>wm', function()
    if vim.t.maximized then
        vim.cmd.tabclose()
    else
        vim.cmd('tab split')
        vim.t.maximized = true
    end
end, 'Toggle window maximize')

-- Toggles. `assist` is the one switch for diagnostics and completion together,
-- for when you want to write without help (see completion.lua).
map('n', '<leader>tw', '<cmd>set wrap!<cr>', 'Toggle wrap')
map('n', '<leader>ts', '<cmd>set spell!<cr>', 'Toggle spell')
map('n', '<leader>tn', '<cmd>set relativenumber!<cr>', 'Toggle relative numbers')
map('n', '<leader>td', function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, 'Toggle diagnostics')
map('n', '<leader>ta', function()
    local on = vim.g.assist == false
    vim.g.assist = on
    vim.diagnostic.enable(on)
    vim.notify('assist ' .. (on and 'on' or 'off'))
end, 'Toggle assist (diagnostics + completion)')

-- Neovim's built-in undo tree.
map('n', '<leader>uu', function()
    pcall(vim.cmd.packadd, 'nvim.undotree')
    vim.cmd('Undotree')
end, 'Undo tree')
