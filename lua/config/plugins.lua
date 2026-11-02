-- The plugin loader: about thirty lines, and the only place that knows how
-- plugins are found. Every file in lua/plugins/ is one feature:
--
--     return {
--         'owner/repo',                              -- a plugin, or several
--         { src = 'owner/repo', version = 'main' },  -- one with a version
--         config = function() ... end,               -- run after loading
--     }
--
-- Files load in alphabetical order. To add a plugin, add a file; to remove one,
-- delete its file and run `:lua vim.pack.del({ 'name' })`. Plugins are fetched by
-- Neovim's own `vim.pack` and pinned in nvim-pack-lock.json (commit it).
local dir = vim.fn.stdpath('config') .. '/lua/plugins/'

local function url(src)
    return src:find('://', 1, true) and src or ('https://github.com/' .. src)
end

local specs, configs = {}, {}
for _, path in ipairs(vim.fn.glob(dir .. '*.lua', false, true)) do
    local name = vim.fn.fnamemodify(path, ':t:r')
    local ok, file = pcall(require, 'plugins.' .. name)
    if not ok then
        vim.notify('plugins/' .. name .. '.lua: ' .. file, vim.log.levels.ERROR)
    else
        for _, entry in ipairs(file) do
            local spec = type(entry) == 'string' and { src = entry } or vim.deepcopy(entry)
            spec.src = url(spec.src)
            specs[#specs + 1] = spec
        end
        if file.config then
            configs[#configs + 1] = { name = name, run = file.config }
        end
    end
end

-- sh/install.sh sets NVIM_INSTALL so the first fetch does not wait for a keypress.
vim.pack.add(specs, { confirm = vim.env.NVIM_INSTALL == nil })

for _, config in ipairs(configs) do
    local ok, err = pcall(config.run)
    if not ok then
        vim.notify('plugins/' .. config.name .. '.lua: ' .. err, vim.log.levels.ERROR)
    end
end
