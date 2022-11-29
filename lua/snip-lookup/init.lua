---@mod snip-lookup

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
-- rust
local rust = require 'snip_lookup_rust'

--------------------------------------
-- Email Addresses:
--   icon: 📧
--   snippets:
--     - john: john.doe@gmail.com
--     - jane: jane.doe@gmail.com
--     - robert: rob.lastname@yahoo.com
--     - dvorak: d.aoeuhts@long.email.domain.com
-- Phone Numbers:
--   icon: ☎️
--   snippets:
--     - john: (111) 111-1111
--     - jane: (222) 222-2222
--     - robert: (333) 333-3333
--     - dvorak: (444) 444-4444
--------------------------------------

local snippets = function(opts, prompt)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = prompt,
        finder = finders.new_table {
            results = {
                { 'john', '(111) 111-1111' },
                { 'jane', '(222) 222-2222' },
                { 'robert', '(333) 333-3333' },
                { 'dvorak', '(444) 444-4444' },
            },
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
                print(vim.inspect(selection))
                local snippet = selection.value[2]
                vim.fn.setreg(vim.v.register, snippet) -- copy to clipboard (system if vim.opt.clipboard is set as such)
                vim.notify(snippet .. ' has been copied!')
            end)
            return true
        end,
    }):find()
end

local categories = function(opts)
    opts = opts or {}
    local prompt = 'Snippet Categories'
    pickers.new(opts, {
        prompt_title = prompt,
        finder = finders.new_table {
            results = {
                { 'Email Addresses', '📧' },
                { 'Phone Numbers', '☎️ ' },
            },
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
                snippets(require('telescope.themes').get_dropdown {}, prompt)
            end)
            return true
        end,
    }):find()
end

P(rust.get_categories())
-- print(rust.something_else())

-- categories(require('telescope.themes').get_dropdown {})
