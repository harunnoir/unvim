-- Commenting. Native `gc` handles line comments; Comment.nvim adds
-- blockwise comments (`gb`) and repeatable motions.
return {
    { src = 'numToStr/Comment.nvim' },
    config = function()
        require('Comment').setup()
    end,
}
