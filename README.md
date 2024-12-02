# Introduction
[dirvish-git.nvim](https://github.com/brianhuster/vim-dirvish-git.lua) is a plugin for Neovim that provides Gitsigns integration for the builtin Netrw file explorer of Vim and [vim-dirvish](https://github.com/justinmk/vim-dirvish) by Justin M. Keyes. Inspired by [vim-dirvish-git](https://github.com/kristijanhusak/vim-dirvish-git) by Kristijan Husak.

# Installation
This plugin requires :
- Neovim 0.5.0+.

Use your favorite plugin manager. Below are some examples : 

* [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'brianhuster/dirvish-git.nvim'
```

* [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "brianhuster/dirvish-git.nvim",
}
```

## mini.deps
```lua
MiniDeps.add({
    source = 'brianhuster/dirvish-git.nvim',
})
```

# Configuration

Note: you can remove any of the icons by setting them to a space.

## Lua

```lua
require('dirvish-git').setup({
    git_icons = {
        modified = '🖋️',
        staged = '✅',
        renamed = '➜',
        unmerged = '❌',
        ignored = '🙈',
        untracked = '❓',
        file = '📄',
        directory = '📁',
	},
})
```

## Vim script

```vim
lua << EOF
require('dirvish-git').setup({
    git_icons = {
        modified = '🖋️',
        staged = '✅',
        renamed = '➜',
        unmerged = '❌',
        ignored = '🙈',
        untracked = '❓',
        file = '📄',
        directory = '📁',
    },
})
EOF
```

# Contributing

If you have any suggestions, bug reports, or contributions, please feel free to open an issue or a pull request.
