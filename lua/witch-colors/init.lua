local M = {}

--- @param opts table?
function M.setup(opts)
    if opts then
        require("witch-colors.config").override(opts)
    end
    require("witch-colors.core").enable()
end

return M
