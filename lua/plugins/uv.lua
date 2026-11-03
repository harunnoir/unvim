-- uv: Python project and package management.
return {
    'benomahony/uv.nvim',
    config = function()
        require('uv').setup({
            picker_integration = true,
        })
    end,
}
