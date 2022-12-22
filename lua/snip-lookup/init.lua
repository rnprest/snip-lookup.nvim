---@mod snip-lookup

local uv = vim.loop
-- Telescope
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
-- Rust
local rust = require 'snip_lookup'
-- snip-lookup stuff
local config = require 'snip-lookup.config'

local M = {}

M.create_config_file = function(path)
    local contents = [[
categories:
  Email Addresses:
    icon: "📧"
    snippets:
      - John Doe: john.doe@gmail.com
      - Jane Doe: jane.doe@gmail.com
  Phone Numbers:
    icon: "☎️"
    snippets:
      - Jack Black: (111) 111-1111
      - Jill Dill: (222) 222-2222
        ]]

    -- Create config directory if it doesn't exist already
    local cleaned_path = vim.fn.fnamemodify(path, ':p')
    local cleaned_path_parent_dir = vim.fn.fnamemodify(path, ':p:h')
    vim.fn.mkdir(cleaned_path_parent_dir, 'p')
    -- Create initial config file, that can be tweaked by user
    uv.fs_open(cleaned_path, 'w', 438, function(err, fd)
        uv.fs_write(fd, contents, 0)
        uv.fs_close(fd)
    end)
end

--- Loads the user's specified configuration and creates their desired keymapping
---@param opts table User-provided options, to override the default options with
M.setup = function(opts)
    -- TODO: need to error if user tries to pass an option that doesn't exist
    if opts ~= nil then
        config.opts = vim.tbl_deep_extend('keep', opts, config.default_opts)
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
    local cleaned_path = vim.fn.fnamemodify(config.opts['config_file'], ':p')
    if vim.fn.filereadable(cleaned_path) == 0 then
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
    local cleaned_path = vim.fn.fnamemodify(config.opts['config_file'], ':p')
    local path_and_categories = cleaned_path .. ',' .. prompt
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
    local cleaned_path = vim.fn.fnamemodify(config.opts['config_file'], ':p')
    local names = rust.get_categories(cleaned_path)
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
