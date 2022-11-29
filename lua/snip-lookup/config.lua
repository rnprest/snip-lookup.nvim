---@mod snip-lookup.config

local M = {}

local config_dir = vim.fn.stdpath 'data' .. '/snip-lookup'

--- These will be applied unless overridden in the setup method
M.default_opts = {
    open_picker = '<leader>sl',
    open_config = '<leader>esl',
    config_dir = config_dir,
    config_file = 'snippets.yaml',
}

-- User's options after overriding within setup function
M.opts = {}
local opts_mt = { __index = M.default_opts }
setmetatable(M.opts, opts_mt)

-- Overwritten in setup func
M.config_file_abs = M.default_opts['config_dir'] .. '/' .. M.default_opts['config_file']

return M
