-- UFO: modern code folding.
return {
    'kevinhwang91/promise-async', -- dep
    'kevinhwang91/nvim-ufo',
    config = function()
        require('ufo').setup({
            provider_selector = function()
                return { 'treesitter', 'indent' }
            end,

            fold_virt_text_handler = function(virt_text, lnum, end_lnum, width, truncate)
                local suffix = (' 󰁂 %d '):format(end_lnum - lnum)
                local suffix_width = vim.fn.strdisplaywidth(suffix)

                local target_width = width - suffix_width
                local result = {}
                local text_width = 0

                for _, chunk in ipairs(virt_text) do
                    local chunk_text = truncate(chunk[1], target_width - text_width)
                    table.insert(result, { chunk_text, chunk[2] })
                    text_width = text_width + vim.fn.strdisplaywidth(chunk_text)

                    if text_width >= target_width then
                        break
                    end
                end

                table.insert(result, { suffix, 'Comment' })
                return result
            end,
        })
    end,
}
