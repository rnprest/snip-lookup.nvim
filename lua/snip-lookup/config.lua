---@mod snip-lookup.config

local M = {}

--- These will be applied unless overridden in the setup method
M.default_opts = {
    open_picker = '<leader>sl',
    open_config = '<leader>esl',
    config_path = '/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml',
}

-- User's options after overriding within setup function
M.opts = {}
local opts_mt = { __index = M.default_opts }
setmetatable(M.opts, opts_mt)

return M
