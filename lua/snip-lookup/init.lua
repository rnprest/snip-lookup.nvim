---@mod snip-lookup

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
-- rust
local rust = require 'snip_lookup_rust'
-- snip-lookup stuff
local config = require 'snip-lookup.config'

local M = {}

--- Loads the user's specified configuration and creates their desired keymapping
---@param opts table User-provided options, to override the default options with
M.setup = function(opts)
    -- TODO: need to error if user tries to pass an option that doesn't exist
    if opts ~= nil then
        config.opts = opts
    end

    vim.api.nvim_set_keymap(
        'n',
        config.opts['open_picker'],
        [[:lua require'snip-lookup'.search()<CR>]],
        { noremap = true }
    )

    -- TODO: fix this

    local command = 'e ' .. config.opts['config_path']
    vim.api.nvim_create_user_command('SnipLookupEdit', command, {})
    vim.api.nvim_set_keymap('n', config.opts['open_config'], ':SnipLookupEdit<CR>', { noremap = true })
end

M.search = function()
    M._categories(require('telescope.themes').get_dropdown {})
end

-- M._get_config_path = function()
--     return config.opts['config_path']
-- end

-- --- These will be applied unless overridden in the setup method
-- M.default_opts = {
--     open_picker = '<leader>sl',
--     open_config = '<leader>esl',
--     config_path = '/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml',
-- }

M._snippets = function(opts, prompt)
    local snippets_results = {}

    ----------------------------------------------------------------------
    --           Load <category's> snippets from config file            --
    ----------------------------------------------------------------------
    -- TODO: grab this path from the setup function
    local path_and_categories = '/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml' .. ',' .. prompt
    local snips = rust.get_snippets(path_and_categories)
    snips = snips.contents

    ----------------------------------------------------------------------
    --            Create telescope results table from loaded            --
    --                             snippets                             --
    ----------------------------------------------------------------------
    local index = 1
    for name, value in pairs(snips) do
        snippets_results[index] = { name, value }
        index = index + 1
    end

    ----------------------------------------------------------------------
    --                     Create telescope picker                      --
    ----------------------------------------------------------------------
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = prompt,
        finder = finders.new_table {
            results = snippets_results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry[1],
                    ordinal = entry[1],
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local snippet = selection.value[2]
                vim.fn.setreg(vim.v.register, snippet) -- copy to clipboard (system if vim.opt.clipboard is set as such)
                vim.notify(snippet .. ' has been copied!')
            end)
            return true
        end,
    }):find()
end

M._categories = function(opts)
    local category_results = {}

    ----------------------------------------------------------------------
    --           Load <category's> snippets from config file            --
    ----------------------------------------------------------------------
    -- TODO: grab this path from the setup function
    local names = rust.get_categories '/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml'
    names = names.contents -- TODO: there's so much wrong with this line

    ----------------------------------------------------------------------
    --            Create telescope results table from loaded            --
    --                             snippets                             --
    ----------------------------------------------------------------------
    local index = 1
    for category, icon in pairs(names) do
        category_results[index] = { category, icon }
        index = index + 1
    end

    ----------------------------------------------------------------------
    --                     Create telescope picker                      --
    ----------------------------------------------------------------------
    opts = opts or {}
    local prompt = 'Snippet Categories'
    pickers.new(opts, {
        prompt_title = prompt,
        finder = finders.new_table {
            results = category_results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry[2] .. ' ' .. entry[1],
                    ordinal = entry[1],
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                prompt = selection.value[1]
                M._snippets(require('telescope.themes').get_dropdown {}, prompt)
            end)
            return true
        end,
    }):find()
end

return M
