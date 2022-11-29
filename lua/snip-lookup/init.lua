---@mod snip-lookup

local uv = vim.loop
-- Telescope
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
-- Plenary -- this is ONLY used to write to the file - try and replace with uv built-in functionality
local Path = require 'plenary.path'
-- Rust
local rust = require 'snip_lookup_rust'
-- snip-lookup stuff
local config = require 'snip-lookup.config'

local M = {}

M.create_config_file = function(path)
    local contents = [[
categories:
  email_addresses:
    icon: "📧"
    snippets:
      - john: john.doe@gmail.com
      - jane: jane.doe@gmail.com
  phone_numbers:
    icon: "☎️"
    snippets:
      - jack: (111) 111-1111
      - jill: (222) 222-2222
        ]]

    -- Create config directory if it doesn't exist already
    vim.fn.mkdir(vim.fn.fnamemodify(config.opts['config_file'], ':p:h'), 'p')
    -- Create initial config file, that can be tweaked by user

    -- uv.fs_open(path, 'r', 438, function(err, fd)
    --     print('fd = ' .. fd)
    --     -- uv.fs_write({fd}, {data} [, {offset} [, {callback}]])            *uv.fs_write()*

    --     --                 Parameters:
    --     --                 - `fd`: `integer`
    --     --                 - `data`: `buffer`
    --     --                 - `offset`: `integer` or `nil`
    --     --                 - `callback`: `callable` (async version) or `nil` (sync
    --     uv.fs_write(fd, contents, 0)
    --     -- uv.fs_read(fd, stat.size, 0, function(err, data)
    --     --     uv.fs_close(fd, function(err)
    --     --         callback(data)
    --     --     end)
    --     -- end)
    -- end)

    Path:new(config.opts['config_file']):write(contents, 'w')
end

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

    ----------------------------------------------------------------------
    --        On first load, need to create initial config file         --
    ----------------------------------------------------------------------
    if vim.fn.filereadable(config.opts['config_file']) == 0 then
        print 'snip-lookup: Config directory not found - Creating'
        -- Create initial config file
        M.create_config_file(config.opts['config_file'])
    end

    -- Create Commands / Keymaps
    local command = 'e ' .. config.opts['config_file']
    vim.api.nvim_create_user_command('SnipLookupEdit', command, {})
    vim.api.nvim_set_keymap('n', config.opts['open_config'], ':SnipLookupEdit<CR>', { noremap = true })
end

M.search = function()
    M._categories(require('telescope.themes').get_dropdown {})
end

M._snippets = function(opts, prompt)
    local snippets_results = {}

    ----------------------------------------------------------------------
    --           Load <category's> snippets from config file            --
    ----------------------------------------------------------------------
    -- TODO: grab this path from the setup function
    local path_and_categories = config.opts['config_file'] .. ',' .. prompt
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
    local names = rust.get_categories(config.opts['config_file'])
    names = names.contents

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
