-- Language servers. A server is a plain table; add one by adding an entry.
-- It is enabled only if its binary exists, so a language you have not installed
-- (sh/lang/*.sh) costs nothing and raises no errors.
local servers = {
    clangd = {
        cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=detailed',
            '--header-insertion=iwyu',
        },
        filetypes = { 'c', 'cpp' },
        root_markers = { '.clangd', 'compile_commands.json', 'compile_flags.txt', 'Makefile', '.git' },
    },

    basedpyright = {
        cmd = { 'basedpyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'uv.lock', 'setup.py', 'requirements.txt', '.git' },
        settings = {
            basedpyright = {
                analysis = {
                    autoImportCompletions = true,
                    -- Checking the whole project on every keystroke is too slow.
                    diagnosticMode = 'openFilesOnly',
                    typeCheckingMode = 'standard',
                },
            },
        },
    },

    gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork' },
        root_markers = { 'go.work', 'go.mod', '.git' },
    },
}

-- Completion needs to tell servers what it can display.
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, 'blink.cmp')
if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
end
vim.lsp.config('*', { capabilities = capabilities, root_markers = { '.git' } })

for name, config in pairs(servers) do
    if vim.fn.executable(config.cmd[1]) == 1 then
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
    end
end

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- Neovim already maps grn (rename), gra (code action), grr (references),
-- gri (implementation), gO (symbols) and K (hover). These are the extras.
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('config_lsp_attach', { clear = true }),
    desc = 'Buffer-local LSP keys',
    callback = function(event)
        local function map(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
        end
        map('gd', vim.lsp.buf.definition, 'Go to definition')
        map('gD', vim.lsp.buf.declaration, 'Go to declaration')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
        map('<leader>cd', vim.diagnostic.open_float, 'Diagnostics on this line')
        map('<leader>ck', vim.lsp.buf.signature_help, 'Signature help')
    end,
})
