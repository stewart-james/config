local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
{
  -- LSP Configuration & Plugins
  {'neovim/nvim-lspconfig', dependencies = {
      { 'williamboman/mason.nvim', config = true },
      { 'williamboman/mason-lspconfig.nvim'},

      -- LSP status updates in bottom right
        -- doesn't work with Omnisharp
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- neovim signature help for init.lua etc..
      { "folke/neodev.nvim", opts = {} }
    },
  },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },


  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- git integration
  'tpope/vim-fugitive',

  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
	add = { text = '+' },
	change = { text = '~' },
	delete = { text = '_' },
	topdelete = { text = '‾' },
	changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
	vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk, { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
	vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
	vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
      },
  },

  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
    },
  },

  -- shows keymaps
  { 'folke/which-key.nvim', opts = {} },

  -- Appearance
  { 'ellisonleao/gruvbox.nvim', priority = 1000 },

  { 'nvim-lualine/lualine.nvim',
      -- See `:help lualine.txt`
      opts = {
	options = {
	  icons_enabled = false,
	  theme = 'gruvbox_dark',
	  component_separators = '|',
	  section_separators = '',
	},
      },
  },

  -- Github Copilot
  { 'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require('copilot').setup({

	panel = {
	  enabled = true,
	  auto_refresh = false,
	  keymap = {
	    jump_prev = "[[",
	    jump_next = "]]",
	    accept = "<CR>",
	    refresh = "gr",
	    open = "<M-CR>"
	  },
	  layout = {
	    position = "bottom", -- | top | left | right
	    ratio = 0.4
	  },
	},

	suggestion = {
	  enabled = true,
	  auto_trigger = true,
	  debounce = 75,
	  keymap = {
	    accept = "<C-a>",
	    accept_word = false,
	    accept_line = false,
	    next = "<C-n>",
	    prev = "<C-p>",
	    dismiss = "<C-q>",
	  },
	},

	filetypes = {
	  yaml = false,
	  markdown = false,
	  help = false,
	  gitcommit = false,
	  gitrebase = false,
	  hgcommit = false,
	  svn = false,
	  cvs = false,
	  cs = true,
	  lua = true,
	  ["."] = false,
	},

	copilot_node_command = 'node', -- Node.js version must be > 16.x
	server_opts_overrides = {},
      })
    end,
  }
})

require('telescope').setup{
	defaults = {
		path_display={"smart"}
	}
}

pcall(require('telescope').load_extension, 'fzf')

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'c_sharp'},

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

