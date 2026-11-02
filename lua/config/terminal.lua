-- Terminal controller.
--
-- Uses Snacks.terminal to manage one persistent shell session.
-- Hiding the terminal keeps the shell and its scrollback alive.
-- The same terminal can be displayed in four layouts:
--
--   <leader>xh  Horizontal split
--   <leader>xv  Vertical split
--   <leader>xf  Floating window
--   <leader>xt  Dedicated tab
--   Ctrl-\      Hide / reopen terminal
--
-- Switching layouts reuses the same terminal buffer and shell process.
-- The session lasts until Neovim exits or the shell terminates.

local api = vim.api

local M = {}

function M.setup()
    local layout = 'horizontal'
    local terminal
    local terminal_tab
    local return_tab
    local cwd = vim.fn.getcwd()

    -- Window settings for each layout.
    local layouts = {
        horizontal = {
            position = 'bottom',
            height = 0.35,
            width = 0.4,
            border = 'none',
            backdrop = false,
        },
        vertical = {
            position = 'right',
            width = 0.4,
            height = 0.35,
            border = 'none',
            backdrop = false,
        },
        float = {
            position = 'float',
            relative = 'editor',
            width = 0.8,
            height = 0.8,
            border = 'rounded',
            backdrop = false,
            zindex = 50,
        },
        tab = {
            position = 'current',
            width = 0,
            height = 0,
            border = 'none',
            backdrop = false,
        },
    }

    -- Create or switch to the dedicated terminal tab.
    local function enter_tab()
        if terminal_tab and api.nvim_tabpage_is_valid(terminal_tab) then
            api.nvim_set_current_tabpage(terminal_tab)
            return
        end

        return_tab = api.nvim_get_current_tabpage()
        vim.cmd.tabnew()
        terminal_tab = api.nvim_get_current_tabpage()
    end

    -- Return to the tab that was active before opening the terminal tab.
    local function leave_tab()
        if terminal_tab
            and api.nvim_tabpage_is_valid(terminal_tab)
            and api.nvim_get_current_tabpage() == terminal_tab
            and return_tab
            and api.nvim_tabpage_is_valid(return_tab)
        then
            api.nvim_set_current_tabpage(return_tab)
        end
    end

    -- Reuse the existing terminal or create it on first use.
    local function get_terminal(name)
        if terminal and terminal:buf_valid() then
            return terminal, false
        end

        local win = vim.tbl_deep_extend(
            'force',
            {
                style = 'terminal',
                wo = {
                    winbar = '',
                },
            },
            layouts[name]
        )

        local created
        terminal, created = Snacks.terminal.get(nil, {
            cwd = cwd,
            count = 1,
            interactive = true,
            win = win,
        })

        return terminal, created
    end

    -- Replace the previous layout's window settings.
    local function apply_layout(term, name)
        for _, key in ipairs({
            'position',
            'relative',
            'height',
            'width',
            'border',
            'backdrop',
            'zindex',
            'title',
            'title_pos',
            'row',
            'col',
        }) do
            term.opts[key] = nil
        end

        for key, value in pairs(layouts[name]) do
            term.opts[key] = value
        end

        -- Keep the terminal window free of its buffer-name winbar.
        term.opts.wo = term.opts.wo or {}
        term.opts.wo.winbar = ''
    end

    -- Display the terminal using the requested layout.
    local function show(name)
        if name == 'tab' then
            enter_tab()
        else
            leave_tab()
        end

        local term, created = get_terminal(name)

        -- Newly created terminals are already visible.
        if not created then
            if term:valid() then
                term:hide()
            end

            apply_layout(term, name)
            term:show()
        end
    end

    -- Hide the window without stopping the shell process.
    local function hide()
        if terminal and terminal:valid() then
            terminal:hide()
        end

        if layout == 'tab' then
            leave_tab()
        end
    end

    -- Toggle the currently selected layout.
    local function toggle()
        if terminal and terminal:valid() then
            hide()
        else
            show(layout)
        end
    end

    -- Change layout while keeping the same terminal session.
    local function select_layout(name)
        if name == layout then
            toggle()
            return
        end

        if terminal and terminal:valid() then
            hide()
        end

        layout = name
        show(name)
    end

    -- Toggle terminal visibility.
    vim.keymap.set({ 'n', 't' }, '<C-\\>', toggle, {
        desc = 'Toggle terminal',
    })

    -- Select terminal layout.
    vim.keymap.set('n', '<leader>xh', function()
        select_layout('horizontal')
    end, { desc = 'Horizontal terminal' })

    vim.keymap.set('n', '<leader>xv', function()
        select_layout('vertical')
    end, { desc = 'Vertical terminal' })

    vim.keymap.set('n', '<leader>xf', function()
        select_layout('float')
    end, { desc = 'Floating terminal' })

    vim.keymap.set('n', '<leader>xt', function()
        select_layout('tab')
    end, { desc = 'Terminal tab' })
end

return M
