vim.o.number = true         -- display line numbers
vim.o.relativenumber = true -- display relative line numbers
vim.o.signcolumn = "yes"    -- always show the sign column
vim.o.wrap = false          -- disable line wrapping
vim.o.tabstop = 4           -- a tab should LOOK like 4 characters
vim.o.softtabstop = 4       -- a tab should insert 1 tab ( equivilent of 4 spaces )
vim.o.shiftwidth = 4        -- a tab should insert 1 column ( equivilent of 4 spaces)
vim.o.expandtab = false     -- use tabs not spaces
vim.o.autoindent = true     -- automatically copy the indentation of the current line when starting a new line
vim.o.splitbelow = true     -- ensure horizontal splits are opened below
vim.o.splitright = true     -- ensure vertical splits are opened to the right
vim.o.swapfile = false      -- disable creation of swapfiles
vim.o.title = true
vim.o.titlestring = [[%t – %{fnamemodify(getcwd(), ':t')}]]

vim.g.mapleader = " "

-- packages
vim.pack.add(
	{
		-- appearance
		{ src = "https://github.com/catppuccin/nvim" },

		-- file tree
		{ src = "https://github.com/nvim-tree/nvim-tree.lua" },

		-- fuzzy find
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
		{ src = "https://github.com/nvim-telescope/telescope.nvim" },

		-- git
		{ src = "https://github.com/lewis6991/gitsigns.nvim" },
		{ src = "https://github.com/NeogitOrg/neogit" },
		{ src = "https://github.com/sindrets/diffview.nvim" },

		-- keymaps
		{ src = "https://github.com/folke/which-key.nvim" },

		-- auto completion
		{ src = "https://github.com/saghen/blink.cmp" },

		-- snippets
		{ src = "https://github.com/L3MON4D3/LuaSnip" },

		-- language servers
		{
			src = "https://github.com/nvim-treesitter/nvim-treesitter",
			version = 'master'
		},

		-- C#
		{ src = "https://github.com/seblyng/roslyn.nvim" },
		{ src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },
		{ src = "https://github.com/DestopLine/boilersharp.nvim" },

		-- misc
		{ src = "https://github.com/folke/todo-comments.nvim" },
		{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
		{ src = "https://github.com/kkoomen/vim-doge" },
	});

local luasnip = require('luasnip')

require('luasnip.loaders.from_vscode').lazy_load {
	exclude = { "csharp" } }
luasnip.config.setup {}
require("snippets")

require("blink.cmp").setup {
	fuzzy = { implementation = "lua" },
	completion =
	{
		list =
		{
			selection =
			{
				preselect = true,
				auto_insert = false
			}
		},
		documentation =
		{
			auto_show = true,
			auto_show_delay_ms = 500
		}
	},
	snippets =
	{
		preset = 'luasnip'
	},
	signature = {
		enabled = true
	},
	keymap =
	{
		preset = 'none',

		['<C-e>'] = { 'hide', 'fallback' },

		['<CR>'] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			'snippet_forward',
			'fallback'
		},

		['<Tab>'] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			'snippet_forward',
			'fallback'
		},

		['<S-Tab>'] = { 'snippet_backward', 'fallback' },

		['<Up>'] = { 'select_prev', 'fallback' },
		['<Down>'] = { 'select_next', 'fallback' },
		['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
		['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

		['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
		['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

		['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },

	}
}

require("nvim-tree").setup {}
require("todo-comments").setup {
	signs = true
}
require("boilersharp").setup {}
require("easy-dotnet").setup {
	test_runner = {
		viewmode = "vsplit",
		vsplit_width = 50,
		vsplit = "topright",
	},
	terminal = function(path, action, args)
		local commands = {
			run = function()
				return string.format("dotnet run --property WarningLevel=0 --project %s %s", path, args)
			end,
			test = function()
				return string.format("dotnet test %s %s", path, args)
			end,
			restore = function()
				return string.format("dotnet restore %s %s", path, args)
			end,
			build = function()
				return string.format("dotnet build %s %s", path, args)
			end,
			watch = function()
				return string.format("dotnet watch --project %s %s", path, args)
			end
		}

		local command = commands[action]() .. "\r"
		vim.cmd("split")
		vim.cmd("resize 30")
		vim.cmd("term " .. command)
		vim.cmd("startinsert")
	end,

}

-- keymaps
local groups =
{
	{ '<leader>s', group = '[S]earch' },
	{ '<leader>l', group = '[L]anguage Server' },
	{ '<leader>c', group = '[C]lose' },
}

local keymaps =
{
	-- general
	{ 'n', '<leader>o',        ':update<CR> :source<CR>',                { silent = true, desc = "Save and source file" } },
	{ 'n', '<leader>w',        ':write<CR>',                             { silent = true, desc = "Write file" } },
	{ 'n', '<leader>q',        ':quit<CR>',                              { silent = true, desc = "Quit" } },
	{ 'n', '<leader>ct',       ':tabclose<CR>',                          { desc = "[C]lose [T]ab" } },
	{ 'n', '<leader><tab>',    '<C-^>',                                  { noremap = true } },

	-- search
	{ 'n', '<leader>sf',       require("telescope.builtin").find_files,  { desc = "[S]earch [F]iles" } },
	{ 'n', '<leader>st',       require("telescope.builtin").git_files,   { desc = "[S]earch GitT] Files" } },
	{ 'n', '<leader>sh',       require("telescope.builtin").help_tags,   { desc = "[S]earch [H]elp" } },
	{ 'n', '<leader>sk',       require("telescope.builtin").keymaps,     { desc = "[S]earch [K]eymaps" } },
	{ 'n', '<leader>sg',       require("telescope.builtin").live_grep,   { desc = "[S]earch [G]rep" } },
	{ 'n', '<leader>sd',       require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" } },
	{ 'n', '<leader>sr',       require("telescope.builtin").oldfiles,    { desc = "[S]earch [R]ecent Files" } },
	{ 'n', '<leader><leader>', require("telescope.builtin").buffers,     { desc = "[ ]Search Buffers" } },

	-- language server
	{ 'n', '<leader>lf',       vim.lsp.buf.format,                       { desc = "LSP Format buffer" } },
	{ 'n', '<leader>lh',       vim.lsp.buf.hover,                        { desc = "LSP Hover" } },
	{ 'n', '<leader>ld',       vim.lsp.buf.definition,                   { desc = "Go to [D]efinition" } },
	{ 'n', '<leader>li',       vim.lsp.buf.implementation,               { desc = "Go to [I]mplementation" } },
	{ 'n', '<leader>lr',       vim.lsp.buf.rename,                       { desc = "[R]ename" } },
	{ 'n', '<leader>la',       vim.lsp.buf.code_action,                  { desc = "Code [A]ction" } },

	-- dotnet stuff
	{ 'n', '<leader>r',        require("easy-dotnet").run_default,       { desc = "[R]un" } },
	{ 'n', '<leader>t',        require("easy-dotnet").testrunner,        { desc = "[T]est" } },
	{ 'n', '<leader>c',        require("easy-dotnet").clean,             { desc = "[C]lean" } },
	{ 'n', '<leader>b',        require("easy-dotnet").build,             { desc = "[B]uild" } },
	{ 'n', '<leader>dbs',      require("easy-dotnet").build_solution,    { desc = "[D]otnet [B]uild [S]olution" } },
	{ 'n', '<leader>dnr',      require("easy-dotnet").restore,           { desc = "[D]otnet [N]uget [R]estore" } },
	{ 'n', '<leader>dts',      require("easy-dotnet").test_solution,     { desc = "[D]otnet [T]est [S]olution" } },

	-- git
	{ 'n', '<leader>n',        ':Neogit<CR>',                            { desc = "[N]eogit" } },

	-- file tree
	{ 'n', '<leader>e',        ':NvimTreeToggle<CR>',                    { desc = "Open Tree [E]xplorer" } },
}

for _, map in ipairs(keymaps) do
	vim.keymap.set(map[1], map[2], map[3], map[4])
end

vim.cmd([[tnoremap <Esc> <C-\><C-n>:call feedkeys("\<C-c>")<CR>]])
vim.cmd([[nnoremap <silent> <Esc> :noh<CR>]])

require('telescope').setup({
	defaults = {
		path_display = { "smart" }
	}
})

require("which-key").add(groups)

-- language servers
local lsps =
{
	lua_ls = {
		cmd = { 'lua-language-server' },
		filetypes = { 'lua' },
		root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
		settings = {
			Lua = {
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				}
			}
		}
	},

	roslyn = {
		cmd = {
			"dotnet",
			"c:/projects/tools/lsp/roslyn/content/LanguageServer/win-x64/Microsoft.CodeAnalysis.LanguageServer.dll",
			"--logLevel=Information",
			"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
			"--stdio",
		},
	}
}

for name, config in pairs(lsps) do
	vim.lsp.config[name] = config
	vim.lsp.enable(name)
end

-- treesitter --
require('nvim-treesitter.configs').setup {
	ensure_installed =
	{
		"c",
		"c_sharp",
		"lua",
		"vim",
		"vimdoc",
		"query",
		"markdown",
		"markdown_inline",
		"xml"
	},

	auto_install = false, -- do not automatically install missing parsers

	highlight = {
		enable = true,
	},
}

vim.cmd("colorscheme catppuccin")

vim.diagnostic.config({ virtual_lines = true })
