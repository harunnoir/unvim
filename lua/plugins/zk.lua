-- Notes. zk manages plain Markdown files; Neovim provides linking,
-- navigation and editing integration.
return {
    { src = 'zk-org/zk-nvim' },
    config = function()
        require('zk').setup({
            picker = 'snacks_picker',
            lsp = {
                config = {
                    name = 'zk',
                    cmd = { 'zk', 'lsp' },
                    filetypes = { 'markdown' },
                },
                auto_attach = {
                    enabled = true,
                },
            },
        })
    end,
}
