<h1 align="center">
  <br>
  snip-lookup.nvim
  <br>
  <br>

![aoeu](https://user-images.githubusercontent.com/47462344/204839108-6dc32a57-1c4b-4921-911e-5220de4a7de8.gif)

</h1>
<h2 align="center">
  <img alt="PR" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat"/>
  <img alt="Lua" src="https://img.shields.io/badge/lua-%232C2D72.svg?&style=flat&logo=lua&logoColor=white"/>
  <img alt="Rust" src="https://img.shields.io/badge/-Rust-orange"/>
</h2>
<h3 align="center">
  <a href="#requirements">Requirements</a> •
  <a href="#installation-and-setup">Installation and Setup</a> •
  <a href="#usage">Usage</a> •
  <a href="#documentation">Documentation</a>
</h3>

Have you amassed such a vast collection of snippets, that remembering the prefixes to use each one is nigh-impossible?

Do you find yourself with too many things you _want_ as snippets, but not enough time to _create all of them_?

**Enter: snip-lookup.nvim!**

---

Let me preface with saying that I LOVE snippets. Whether I'm using them to
quickly type out my home address, or for commonly-typed code-snippets - I find
myself constantly using or creating them.

That being said, I also have have several "wants" that I (until now) _haven't_ been able to fulfill:

- I want editing my snippets to be fast and easy, so I can tweak them on the fly
- I want to version control my snippets, so I can use them across multiple computers
- I want to categorize my snippets, so I can quickly know what snippets I have
- I want to fuzzy-search through my snippets, so I can select snippets faster

**snip-lookup.nvim solves those by:**

- Storing all your snippets in a simple YAML file of your choosing
  - Specify a file path to easily version control your snippets!
  - For example, you can store your work-specific snippets in a work repository
- Providing a keybind for instantly editing your snippets
- Utilizing [telescope](https://github.com/nvim-telescope/telescope.nvim) to fuzzy-search through existing categories/snippets

## Requirements

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Cargo (For building from source)

## Installation and Setup

Using [packer](https://github.com/wbthomason/packer.nvim):

```lua
use {
    'rnprest/snip-lookup.nvim',
        requires = { 'nvim-telescope/telescope.nvim' },
        run = './build.sh',
        config = function()
            require('snip-lookup').setup {
                -- Default options are listed below - you can just call setup() if these are fine with you
                open_picker = '<leader>sl',
                open_config = '<leader>esl',
                config_file = vim.fn.stdpath 'data' .. '/snip-lookup/snippets.yaml',
            }
    end,
}
```

## Usage

Searching through your snippets

1. Hit `<leader>sl`
2. Start typing the name of your category
   - Hit `<CR>` to select a category
3. Start typing the name of your snippet
   - Hit `<CR>` to copy the selected snippet to your clipboard

Editing your snippets

1. Hit `<leader>esl`
2. Start editing to your heart's content
   - To save your changes, just save the file.
   - Any changes made will be immediately available the next time you hit your search remap

# Documentation

Snippet file structure:

```
categories:
  <snippet category>:
    icon: <icon> # Setting this is OPTIONAL, and will default to blank space
    snippets:
      - <snippet name>: <snippet contents>
      - ...
  ...
```

Example (This will be the default contents of your snippet file):

```yaml
categories:
  Email Addresses:
    icon: 📧
    snippets:
      - John Doe: john.doe@gmail.com
      - Jane Doe: jane.doe@gmail.com
  Phone Numbers:
    icon: 📞
    snippets:
      - Jack Black: (111) 111-1111
      - Jill Dill: (222) 222-2222
  File Templates:
    snippets:
      - README: |-
          # Title

          ## Installation

          ## Usage
  Email Groups:
    snippets:
      - Family: >-
          mom@gmail.com;
          dad@hotmail.com;
          brother@aol.com;
          sister@yahoo.com;
          son@proton.me;
          daughter@outlook.com
```
