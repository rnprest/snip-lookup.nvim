---@mod snip-lookup.config

local M = {}

--- These will be applied unless overridden in the setup method
M.default_opts = {
    open_picker = '<leader>sl',
    open_config = '<leader>esl',
    config_file = vim.fn.stdpath 'data' .. '/snip-lookup/snippets.yaml',
}

-- User's options after overriding within setup function
M.opts = {}

return M
