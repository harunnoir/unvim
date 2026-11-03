-- Editor options. Grouped by purpose, not alphabetically.
local opt = vim.opt

-- Tools installed by sh/ live in these. Add them to PATH only if they exist and
-- are not already there, so a shell that forgot to export them still works.
local home = vim.uv.os_homedir() or vim.env.HOME
for _, dir in ipairs({ home .. '/go/bin', home .. '/.cargo/bin', home .. '/.local/bin' }) do
    local present = (':' .. vim.env.PATH .. ':'):find(':' .. dir .. ':', 1, true)
    if vim.fn.isdirectory(dir) == 1 and not present then
        vim.env.PATH = dir .. ':' .. vim.env.PATH
    end
end

-- Files: undo history survives, no swap or backup litter.
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.autowrite = true
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.ttimeoutlen = 10

-- Search.
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
if vim.fn.executable('rg') == 1 then
    opt.grepprg = 'rg --vimgrep --smart-case --hidden'
    opt.grepformat = '%f:%l:%c:%m'
end

-- Indentation. Per-filetype overrides live in autocmds.lua.
opt.expandtab = true
opt.smartindent = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

-- Interface.
opt.laststatus = 3
opt.showmode = false
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = 'yes'
opt.scrolloff = 4
opt.sidescrolloff = 4
opt.wrap = false
opt.linebreak = true
opt.smoothscroll = true
opt.winborder = 'rounded'
opt.pumheight = 12
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.shortmess:append('Ic')

-- Splits open where the eye already is.
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = 'screen'

-- Make trailing spaces and tabs visible.
opt.list = true
opt.listchars = { tab = '› ', trail = '·', nbsp = '␣' }
opt.fillchars = {
    eob = ' ',
    fold = ' ',
    foldopen = '⌄',
    foldclose = '›',
    foldsep = ' ',
}

-- Folds are managed by nvim-ufo, using Tree-sitter and indentation.
opt.foldcolumn = '1'
opt.foldmethod = 'manual'
opt.foldexpr = ''
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Neovide only; these globals do nothing in a terminal.
if vim.g.neovide then
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_cursor_animation_length = 0.06
end
