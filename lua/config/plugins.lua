-- ============================================================================
-- 📦 Plugin Specification Template
--
-- Each file in lua/plugins/ returns a table of plugin specs. Entries can be:
--
--   1. String (GitHub shorthand):
--      'sainnhe/gruvbox-material'
--
--   2. Table with src (required) + optional fields:
--      { src = 'sainnhe/gruvbox-material', version = 'main' }
--      { src = 'some/package', lazy = true, dev = 0 }
--
--   3. Grouped table (install multiple at once):
--      { 'plugin1', 'plugin2', 'plugin3' }
--
--   4. With config function (runs after install):
--      { src = 'owner/repo', config = function() require('plugin').setup() end }
--
-- Supported fields per spec table:
--   src    - source (GitHub 'owner/repo' or full URL)  REQUIRED
--   version- 'main', a git tag, or '*' (latest)         defaults to 'main' for GitHub
--   lazy   - boolean   (future: skip on startup)       defaults to false
--   dev    - boolean or number (dev version marker)
--   config - function  (runs after plugin is loaded)
--
-- Example full spec:
--   { src = 'sainnhe/gruvbox-material', version = 'main', lazy = false,
--     config = function() vim.g.gruvbox_material_background = 'soft' end }
--
-- Files are loaded alphabetically. After editing, restart Neovim or run:
--   :lua vim.pack.update()
-- ============================================================================

-- The plugin loader: supports lazy.nvim-compatible spec tables, grouped
-- specifications, and flat entries. Every file in lua/plugins/ is one feature.
--
-- Supported spec formats (all backward-compatible):
--   'owner/repo'                                                    -> GitHub shorthand
--   { src = 'owner/repo', version = 'main' }                        -> with version
--   { 'plugin1', 'plugin2' }                                        -> grouped install
--   { src = 'owner/repo', lazy = true, config = function() ... end } -> full control
--
-- Files load in alphabetical order. To add a plugin, add an entry to any
-- plugin file; to remove one, delete the entry and restart Neovim.
-- Plugins are fetched by Neovim's own `vim.pack` and pinned in
-- nvim-pack-lock.json (commit it).

local dir = vim.fn.stdpath('config') .. '/lua/plugins/'

-- Convert GitHub owner/repo shorthand to full GitHub URL.
local function url(src)
    return src:find('://', 1, true) and src or ('https://github.com/' .. src)
end

-- Ensure a spec has a src field; returns nil if invalid.
local function ensure_src(spec)
    if type(spec) == 'string' then return spec end
    if type(spec) ~= 'table' then return nil end
    return spec.src
end

-- Validate a plugin spec and return a normalized table, or nil if malformed.
-- Supports these entry formats (all backward-compatible):
--   1. String:        'owner/repo'           -> { src = 'owner/repo' }
--   2. Single table:  { src = 'owner/repo' }   -> as-is
--   3. Grouped flat:  { 'a', 'b' }             -> install both as separate specs
--   4. Nested/grouped {{src='a'}, {src='b'}}   -> table of table specs
local function validate_spec(entry)
    -- 1. String (GitHub shorthand)
    if type(entry) == 'string' then
        return { src = entry }, nil

    -- 2. Table
    elseif type(entry) == 'table' then
        -- Check if this is a grouped flat table: { 'plugin1', 'plugin2' }
        -- where all elements are strings (not a 'src' table)
        local all_strings = true
        for _, v in ipairs(entry) do
            if type(v) ~= 'string' then
                all_strings = false
                break
            end
        end

        if #entry > 0 and all_strings then
            -- Format 3: Grouped flat { 'a', 'b' } -> return multiple specs
            local specs = {}
            for _, name in ipairs(entry) do
                table.insert(specs, { src = name })
            end
            return specs, nil
        end

        -- Format 4: Nested/grouped {{src='a'}, {src='b'}} or {src='a'}
        -- Deep copy the entry
        local spec = vim.deepcopy(entry)

        -- Check if this is a table of table specs: {{src='a'}, {src='b'}}
        -- where all elements are tables with a 'src' field
        local all_tables_with_src = true
        if #spec > 0 then
            for _, v in ipairs(spec) do
                if type(v) ~= 'table' or not v.src then
                    all_tables_with_src = false
                    break
                end
            end
        end

        if #spec > 0 and all_tables_with_src then
            -- Return multiple specs, one for each inner table
            local specs = {}
            for _, inner in ipairs(spec) do
                -- Make a copy and normalize
                local inner_spec = vim.deepcopy(inner)
                if not inner_spec.src then
                    return nil, 'nested spec is missing src field'
                end
                inner_spec.src = url(inner_spec.src)
                if not inner_spec.version then
                    if inner_spec.src:find('github%.com', 1, true) then
                        inner_spec.version = 'main'
                    else
                        inner_spec.version = nil
                    end
                end
                local allowed = { src = true, version = true, lazy = true, dev = true }
                for k in pairs(inner_spec) do
                    if not allowed[k] then
                        inner_spec[k] = nil
                    end
                end
                if inner_spec.version and type(inner_spec.version) ~= 'string' then
                    inner_spec.version = tostring(inner_spec.version)
                end
                table.insert(specs, inner_spec)
            end
            return specs, nil
        end

        -- Single spec table (not a group): {src='a'} or {src='a', version='main'}
        if not spec.src then
            return nil, 'spec is missing src field'
        end

        -- Normalize url
        spec.src = url(spec.src)

        -- Set default version: 'main' for GitHub repos without explicit version
        if not spec.version then
            if spec.src:find('github%.com', 1, true) then
                spec.version = 'main'
            else
                spec.version = nil
            end
        end

        -- Whitelist allowed fields; strip anything else
        local allowed = { src = true, version = true, lazy = true, dev = true }
        for k in pairs(spec) do
            if not allowed[k] then
                spec[k] = nil
            end
        end

        -- Ensure version is a string if present
        if spec.version and type(spec.version) ~= 'string' then
            spec.version = tostring(spec.version)
        end

        return { spec }, nil
    end

    return nil, 'spec must be a string or table'
end

local specs, configs = {}, {}
for _, path in ipairs(vim.fn.glob(dir .. '*.lua', false, true)) do
    local name = vim.fn.fnamemodify(path, ':t:r')
    local ok, file = pcall(require, 'plugins.' .. name)
    if not ok then
        vim.notify('plugins/' .. name .. '.lua: ' .. file, vim.log.levels.ERROR)
    else
        for _, entry in ipairs(file) do
            local spec, err = validate_spec(entry)
            if not spec then
                vim.notify('plugins/' .. name .. ': ' .. err, vim.log.levels.ERROR)
            else
                -- validate_spec may return a single spec or a table of specs (from grouped flat)
                if type(spec) == 'table' then
                    -- If it's a table of specs (from { 'a', 'b' } format), add each one
                    if #spec > 0 and type(spec[1]) == 'table' and spec[1].src then
                        for _, s in ipairs(spec) do
                            specs[#specs + 1] = s
                        end
                    else
                        -- Single spec table, add as-is
                        specs[#specs + 1] = spec
                    end
                else
                    -- Fallback: wrap in table
                    specs[#specs + 1] = spec
                end
            end
        end
        if file.config then
            configs[#configs + 1] = { name = name, run = file.config }
        end
    end
end

-- sh/install.sh sets NVIM_INSTALL so the first fetch does not wait for a keypress.
vim.pack.add(specs, { confirm = vim.env.NVIM_INSTALL == nil })

for _, cfg in ipairs(configs) do
    local ok, err = pcall(cfg.run)
    if not ok then
        vim.notify('plugins/' .. cfg.name .. '.lua: ' .. err, vim.log.levels.ERROR)
    end
end
