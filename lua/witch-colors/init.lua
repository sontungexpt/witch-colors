local M = {}

--- @param opts table?
function M.setup(opts)
    local Config = require("witch-colors.config")
    local Core = require("witch-colors.core")
    Config.override(opts)
    Core.setup()
end

return M
