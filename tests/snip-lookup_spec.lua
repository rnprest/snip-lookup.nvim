local find_map = function(lhs)
    local maps = vim.api.nvim_get_keymap 'n'
    for _, map in ipairs(maps) do
        if map.lhs == lhs then
            return map
        end
    end
end

describe('setup defaults', function()
    before_each(function()
        require('snip-lookup').setup()
    end)
    it('is setting the edit remap', function()
        require('snip-lookup').setup()
        local rhs = ':SnipLookupEdit<CR>'
        local found = find_map ',esl'
        assert.are.same(rhs, found.rhs)
    end)
    it('is setting the search remap', function()
        require('snip-lookup').setup()
        local rhs = [[:lua require'snip-lookup'.search()<CR>]]
        local found = find_map ',sl'
        assert.are.same(rhs, found.rhs)
    end)

    it('is setting the default config path', function()
        local config_path = vim.fn.stdpath 'data' .. '/snip-lookup/snippets.yaml'
        local cleaned_path = vim.fn.fnamemodify(config_path, ':p')
        assert.are.same(1, vim.fn.filereadable(cleaned_path))
    end)
end)

describe('override defaults', function()
    before_each(function()
        require('snip-lookup').setup {
            open_picker = 'aoeu',
            open_config = 'htns',
            config_file = '~/test/test/test/test/test.yaml',
        }
    end)
    it('is setting the edit remap', function()
        require('snip-lookup').setup()
        local rhs = ':SnipLookupEdit<CR>'
        local found = find_map 'htns'
        assert.are.same(rhs, found.rhs)
    end)
    it('is setting the search remap', function()
        require('snip-lookup').setup()
        local rhs = [[:lua require'snip-lookup'.search()<CR>]]
        local found = find_map 'aoeu'
        assert.are.same(rhs, found.rhs)
    end)

    it('is setting the default config path', function()
        local config_path = '~/test/test/test/test/test.yaml'
        local cleaned_path = vim.fn.fnamemodify(config_path, ':p')
        assert.are.same(1, vim.fn.filereadable(cleaned_path))
    end)
end)
