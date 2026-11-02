
-- Custom highlight overrides.
--
-- Keep all personal highlight customizations here.
-- Plugin configurations should only handle plugin behavior.
--
-- Add colorscheme-specific overrides inside the matching
-- colorscheme section. Reapply them whenever the colorscheme changes.

local api = vim.api

local function gruvbox_material()
    -- render-markdown.nvim
    local markdown = {
        -- Headings.
        RenderMarkdownH1 = { fg = '#ea6962', bold = true },
        RenderMarkdownH2 = { fg = '#e78a4e', bold = true },
        RenderMarkdownH3 = { fg = '#d8a657', bold = true },
        RenderMarkdownH4 = { fg = '#a9b665', bold = true },
        RenderMarkdownH5 = { fg = '#89b482', bold = true },
        RenderMarkdownH6 = { fg = '#7daea3', bold = true },

        -- Heading backgrounds.
        RenderMarkdownH1Bg = { bg = '#3c3836' },
        RenderMarkdownH2Bg = { bg = '#3c3836' },
        RenderMarkdownH3Bg = { bg = '#3c3836' },
        RenderMarkdownH4Bg = { bg = '#3c3836' },
        RenderMarkdownH5Bg = { bg = '#3c3836' },
        RenderMarkdownH6Bg = { bg = '#3c3836' },

        -- Code.
        RenderMarkdownCode = { bg = '#3c3836' },
        RenderMarkdownCodeInline = {
            fg = '#e78a4e',
            bg = '#45403d',
        },
        RenderMarkdownCodeBorder = { bg = '#3c3836' },
        RenderMarkdownCodeInfo = { fg = '#928374', italic = true },

        -- Lists and quotes.
        RenderMarkdownBullet = { fg = '#d8a657' },
        RenderMarkdownQuote = { fg = '#89b482', italic = true },
        RenderMarkdownDash = { fg = '#928374' },

        -- Links.
        RenderMarkdownLink = { fg = '#7daea3', underline = true },

        -- Checkboxes.
        RenderMarkdownUnchecked = { fg = '#928374' },
        RenderMarkdownChecked = { fg = '#a9b665' },
        RenderMarkdownTodo = { fg = '#d8a657' },

        -- Tables.
        RenderMarkdownTableHead = { fg = '#d8a657', bold = true },
        RenderMarkdownTableRow = { fg = '#ddc7a1' },
        RenderMarkdownTableFill = { fg = '#665c54' },

        -- Callouts.
        RenderMarkdownSuccess = { fg = '#a9b665' },
        RenderMarkdownInfo = { fg = '#7daea3' },
        RenderMarkdownHint = { fg = '#89b482' },
        RenderMarkdownWarn = { fg = '#d8a657' },
        RenderMarkdownError = { fg = '#ea6962' },
    }

    for group, settings in pairs(markdown) do
        api.nvim_set_hl(0, group, settings)
    end
end

local function apply_highlights()
    local colorscheme = vim.g.colors_name

    if colorscheme == 'gruvbox-material' then
        gruvbox_material()
    end
end

-- Apply overrides after the colorscheme is loaded or changed.
api.nvim_create_autocmd('ColorScheme', {
    group = api.nvim_create_augroup('user_highlights', { clear = true }),
    callback = apply_highlights,
})

-- Apply once during startup if the colorscheme is already loaded.
apply_highlights()
