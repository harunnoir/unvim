local BaseProvider = require('99.providers').BaseProvider

local AgyProvider = setmetatable({}, { __index = BaseProvider })

function AgyProvider._build_command(_, query, context)
    local script = [[
agy -p "$1" \
    --model "$2" \
    --effort medium \
    --output-format json |
    jq -er '.response' |
    sed '1d; $d' > "$3"
]]

    return {
        'bash',
        '-o',
        'pipefail',
        '-c',
        script,
        'agy',
        query,
        context.model,
        context.tmp_file,
    }
end

function AgyProvider._get_provider_name()
    return 'AgyProvider'
end

function AgyProvider._get_default_model()
    return 'gemini-3.8-flash-medium'
end

return AgyProvider
