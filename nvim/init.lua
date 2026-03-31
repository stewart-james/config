-- ─────────────────────────────────────────────────────────────────────────────
-- Options
-- ─────────────────────────────────────────────────────────────────────────────
vim.o.number         = true
vim.o.relativenumber = true
vim.o.signcolumn     = "yes"
vim.o.wrap           = false
vim.o.tabstop        = 4
vim.o.softtabstop    = 4
vim.o.shiftwidth     = 4
vim.o.expandtab      = false
vim.o.autoindent     = true
vim.o.splitbelow     = true
vim.o.splitright     = true
vim.o.swapfile       = false
vim.o.clipboard      = "unnamedplus"
vim.o.title          = true
vim.o.titlestring    = [[%t – %{fnamemodify(getcwd(), ':t')}]]
vim.o.termguicolors  = true
vim.o.cursorline     = true
vim.o.showmode       = false  -- lualine shows mode
vim.o.laststatus     = 3      -- global statusline
vim.o.cmdheight      = 1

vim.cmd("set completeopt+=noselect")

vim.diagnostic.config({ virtual_text = { prefix = "●" } })

vim.g.mapleader = " "

-- ─────────────────────────────────────────────────────────────────────────────
-- Plugins
-- ─────────────────────────────────────────────────────────────────────────────
vim.pack.add({
	-- appearance
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify" },
	{ src = "https://github.com/folke/noice.nvim" },

	-- file tree
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },

	-- fuzzy find
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },

	-- auto complete
	{ src = "https://github.com/saghen/blink.cmp" },

	-- git
	{ src = "https://github.com/NeogitOrg/neogit" },
	{ src = "https://github.com/sindrets/diffview.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },

	-- editing
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/kylechui/nvim-surround" },

	-- navigation
	{ src = "https://github.com/folke/flash.nvim" },

	-- diagnostics
	{ src = "https://github.com/folke/trouble.nvim" },

	-- formatting
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- utilities
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/folke/persistence.nvim" },
	{ src = "https://github.com/karb94/neoscroll.nvim" },

	-- navigation
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },


	-- keymaps
	{ src = "https://github.com/folke/which-key.nvim" },

	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "master" },
	{ src = "https://github.com/ray-x/lsp_signature.nvim" },

	-- debug
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },

	-- dotnet
	{ src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },

	-- markdown
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },

	-- AI
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/yetone/avante.nvim" },
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Appearance
-- ─────────────────────────────────────────────────────────────────────────────
require("catppuccin").setup({
	flavour = "mocha",
	integrations = {
		treesitter      = true,
		telescope       = { enabled = true },
		which_key       = true,
		mason           = true,
		neogit          = true,
		diffview        = true,
		dap             = true,
		dap_ui          = true,
		nvimtree        = true,
		blink_cmp       = true,
		render_markdown = true,
		lualine         = true,
		gitsigns        = true,
		notify          = true,
		noice           = true,
	},
	custom_highlights = function(c)
		return {
			-- Relative line numbers: readable but clearly secondary
			LineNr       = { fg = c.overlay1 },
			-- Current line number: bold mauve, matches the mode indicator
			CursorLineNr = { fg = c.mauve, bold = true },
		}
	end,
})

local arrow = { left = "", right = "" }
local thin  = { left = "", right = "" }

require("lualine").setup({
	options = {
		theme                = "auto",
		section_separators   = arrow,
		component_separators = thin,
		globalstatus         = true,
	},
	sections = {
		lualine_a = {},
		lualine_b = { "branch", "diff", { "diagnostics", symbols = { error = " ", warn = " ", info = " " } } },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	tabline = {
		lualine_a = { { "tabs", mode = 2, path = 1, tabs_color = {
			active   = "lualine_a_normal",
			inactive = "lualine_b_normal",
		}}},
		lualine_z = { "filename" },
	},
})

-- ─────────────────────────────────────────────────────────────────────────────
-- LSP / Treesitter
-- ─────────────────────────────────────────────────────────────────────────────
require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})
require("mason-lspconfig").setup()

require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "css", "c_sharp", "razor", "vim", "vimdoc", "query", "markdown", "markdown_inline", "xml", "html" },
	highlight = { enable = true },
})

require("lsp_signature").setup({
	hint_enable     = true,
	floating_window = true,
})

vim.lsp.config("roslyn", {})

-- ─────────────────────────────────────────────────────────────────────────────
-- Completion
-- ─────────────────────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		if vim.startswith(vim.api.nvim_buf_get_name(ev.buf), "diffview://") then
			vim.lsp.buf_detach_client(ev.buf, ev.data.client_id)
			return
		end
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Git
-- ─────────────────────────────────────────────────────────────────────────────
local function preview_diffview_file_under_cursor()
	local ok, lib = pcall(require, "diffview.lib")
	if not ok then return end

	local view = lib.get_current_view()
	if not view or not view.panel or not view.panel:is_focused() then return end

	local file = view:infer_cur_file(false)
	if not file then return end

	view:set_file(file, false, false)
end

require("gitsigns").setup({
	signs = {
		add          = { text = "▎" },
		change       = { text = "▎" },
		delete       = { text = "" },
		topdelete    = { text = "" },
		changedelete = { text = "▎" },
		untracked    = { text = "▎" },
	},
	on_attach = function(bufnr)
		local gs = require("gitsigns")
		local map = function(mode, l, r, desc)
			vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
		end
		map("n", "]h", gs.next_hunk,                      "Next hunk")
		map("n", "[h", gs.prev_hunk,                      "Prev hunk")
		map("n", "<leader>hs", gs.stage_hunk,             "[H]unk [S]tage")
		map("n", "<leader>hr", gs.reset_hunk,             "[H]unk [R]eset")
		map("n", "<leader>hp", gs.preview_hunk,           "[H]unk [P]review")
		map("n", "<leader>hb", gs.blame_line,             "[H]unk [B]lame")
		map("n", "<leader>hd", gs.diffthis,               "[H]unk [D]iff")
	end,
})

require("diffview").setup({
	file_panel = {
		win_config   = { width = 60 },
		indent_width = 1,
	},
	keymaps = {
		file_panel = {
			["j"]      = function() vim.cmd.normal({ "j", bang = true }) preview_diffview_file_under_cursor() end,
			["k"]      = function() vim.cmd.normal({ "k", bang = true }) preview_diffview_file_under_cursor() end,
			["<Down>"] = function() vim.cmd.normal({ "j", bang = true }) preview_diffview_file_under_cursor() end,
			["<Up>"]   = function() vim.cmd.normal({ "k", bang = true }) preview_diffview_file_under_cursor() end,
		},
	},
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Debug
-- ─────────────────────────────────────────────────────────────────────────────
local dap   = require("dap")
local dapui = require("dapui")

dapui.setup()

-- DAP signs
vim.fn.sign_define("DapBreakpoint",         { text = "●", texthl = "DapBreakpoint",         linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition",{ text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint",           { text = "◆", texthl = "DapLogPoint",            linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped",            { text = "▶", texthl = "DapStopped",             linehl = "DapStopped", numhl = "" })

vim.api.nvim_set_hl(0, "DapBreakpoint",          { fg = "#f38ba8" }) -- red
vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f9e2af" }) -- yellow
vim.api.nvim_set_hl(0, "DapBreakpointRejected",  { fg = "#6c7086" }) -- muted
vim.api.nvim_set_hl(0, "DapLogPoint",            { fg = "#89b4fa" }) -- blue
vim.api.nvim_set_hl(0, "DapStopped",             { fg = "#a6e3a1" }) -- green

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open()  end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

-- ─────────────────────────────────────────────────────────────────────────────
-- Dotnet
-- ─────────────────────────────────────────────────────────────────────────────
require("easy-dotnet").setup({
	test_runner = {
		viewmode     = "float",
		vsplit_width = nil,
		vsplit       = "topright",
	},
	terminal = function(path, action, args)
		local commands = {
			run     = function() return string.format("dotnet run --project %s %s", path, args) end,
			test    = function() return string.format("dotnet test %s %s", path, args) end,
			restore = function() return string.format("dotnet restore %s %s", path, args) end,
			build   = function() return string.format("dotnet build %s %s", path, args) end,
			watch   = function() return string.format("dotnet watch --project %s %s", path, args) end,
		}
		local command = commands[action]() .. "\r"
		vim.cmd("split")
		vim.cmd("resize 30")
		vim.cmd("term " .. command)
	end,
	notifications = {
		handler = false
	}
})

-- ─────────────────────────────────────────────────────────────────────────────
-- File tree / Telescope / Markdown / AI
-- ─────────────────────────────────────────────────────────────────────────────
require("nvim-tree").setup({ view = { width = 60 } })

require("telescope").setup({
	defaults = {
		file_ignore_patterns = { "%.exe$", "%.dll$", "%.wdp$", "%.sys$", "%.rc$", "%.inf$", "%.png$" },
		path_display = function(_, path)
			local parts = vim.split(path, "\\")
			local n     = 3
			if #parts < n then return path end
			return table.concat(vim.list_slice(parts, #parts - n + 1, #parts), "/")
		end,
	},
})

require("render-markdown").setup({
	file_types = { "markdown", "Avante" },
})

require("copilot").setup({
	suggestion = { enabled = false },
	panel      = { enabled = false },
})

require("avante").setup({ provider = "copilot" })

-- ─────────────────────────────────────────────────────────────────────────────
-- Editing
-- ─────────────────────────────────────────────────────────────────────────────
require("nvim-autopairs").setup({ check_ts = true })
require("nvim-surround").setup()

require("flash").setup({
	modes = {
		search = { enabled = false }, -- don't hijack / search
	},
})

require("neoscroll").setup({ easing = "sine", duration_multiplier = 0.3 })

require("todo-comments").setup()

require("persistence").setup()

local harpoon = require("harpoon")
harpoon:setup()


require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		cs  = { "csharpier" },
	},
	format_on_save = {
		timeout_ms   = 2000,
		lsp_fallback = true,
	},
})

require("trouble").setup()

-- ─────────────────────────────────────────────────────────────────────────────
-- UI (Noice)
-- ─────────────────────────────────────────────────────────────────────────────
require("notify").setup({ background_colour = "#1e1e2e" })
vim.notify = require("notify")

require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"]                = true,
		},
	},
	presets = {
		bottom_search         = true,
		long_message_to_split = true,
		lsp_doc_border        = true,
	},
	views = {
		cmdline_popup = {
			position = { row = "90%", col = "50%" },
		},
	},
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Keymaps
-- ─────────────────────────────────────────────────────────────────────────────
require("which-key").add({
	{ "<leader>s", group = "[S]earch" },
	{ "<leader>l", group = "[L]anguage Server" },
	{ "<leader>c", group = "[C]lose" },
	{ "<leader>h", group = "[H]unk (git)" },
	{ "<leader>x", group = "[X] Trouble diagnostics" },
	{ "<leader>p", group = "[P]ersistence" },
	{ "<leader>i", group = "[I]AI" },
})

local keymaps = {
	-- clear search highlight
	{ "n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" } },

	-- general
	{ "n", "<leader>o",        ":update<CR> :source<CR>",                   { silent = true, desc = "Save and source file" } },
	{ "n", "<leader>w",        ":write<CR>",                                 { silent = true, desc = "Write file" } },
	{ "n", "<leader>q",        ":quit<CR>",                                  { silent = true, desc = "Quit" } },
	{ "n", "<leader>ct",       ":tabclose<CR>",                              { desc = "[C]lose [T]ab" } },
	{ "n", "<leader><tab>",    "<C-^>",                                      { noremap = true } },

	-- search
	{ "n", "<leader>sf",       require("telescope.builtin").find_files,      { desc = "[S]earch [F]iles" } },
	{ "n", "<leader>st",       require("telescope.builtin").git_files,       { desc = "[S]earch [G]it Files" } },
	{ "n", "<leader>sh",       require("telescope.builtin").help_tags,       { desc = "[S]earch [H]elp" } },
	{ "n", "<leader>sk",       require("telescope.builtin").keymaps,         { desc = "[S]earch [K]eymaps" } },
	{ "n", "<leader>sg",       require("telescope.builtin").live_grep,       { desc = "[S]earch [G]rep" } },
	{ "n", "<leader>sd",       require("telescope.builtin").diagnostics,     { desc = "[S]earch [D]iagnostics" } },
	{ "n", "<leader>sr",       require("telescope.builtin").oldfiles,        { desc = "[S]earch [R]ecent Files" } },
	{ "n", "<leader><leader>", require("telescope.builtin").buffers,         { desc = "[ ] Search Buffers" } },

	-- language server
	{ "n", "<leader>lf",       function() require("conform").format({ lsp_fallback = true }) end, { desc = "Format buffer" } },
	{ "n", "<leader>lh",       vim.lsp.buf.hover,                            { desc = "LSP Hover" } },
	{ "n", "<leader>ld",       vim.lsp.buf.definition,                       { desc = "Go to [D]efinition" } },
	{ "n", "<leader>li",       vim.lsp.buf.implementation,                   { desc = "Go to [I]mplementation" } },
	{ "n", "<leader>lr",       vim.lsp.buf.rename,                           { desc = "[R]ename" } },
	{ "n", "<leader>la",       vim.lsp.buf.code_action,                      { desc = "Code [A]ction" } },
	{ "n", "<leader>llr",      vim.lsp.buf.references,                       { desc = "[L]ist [R]eferences" } },
	{ "n", "<leader>le",       vim.diagnostic.open_float,                    { desc = "LSP [E]rror" } },

	-- dotnet
	{ "n", "<leader>r",        require("easy-dotnet").run,                   { desc = "[R]un" } },
	{ "n", "<leader>t",        require("easy-dotnet").testrunner,            { desc = "[T]est" } },
	{ "n", "<leader>c",        require("easy-dotnet").clean,                 { desc = "[C]lean" } },
	{ "n", "<leader>dbs",      require("easy-dotnet").build_solution,        { desc = "[D]otnet [B]uild [S]olution" } },
	{ "n", "<leader>dnr",      require("easy-dotnet").restore,               { desc = "[D]otnet [N]uget [R]estore" } },
	{ "n", "<leader>dts",      require("easy-dotnet").test_solution,         { desc = "[D]otnet [T]est [S]olution" } },
	{ "n", "<leader>dtr",      require("easy-dotnet").testrunner,            { desc = "[D]otnet [T]est [R]unner" } },

	-- debugger
	{ "n", "<leader>b",        require("dap").toggle_breakpoint,             { desc = "Toggle [B]reakpoint" } },
	{ "n", "<F5>",             require("dap").continue,                      { desc = "Start/continue debugging" } },
	{ "n", "<F10>",            require("dap").step_over,                     { desc = "Step over" } },
	{ "n", "<F11>",            require("dap").step_into,                     { desc = "Step into" } },
	{ "n", "<F12>",            require("dap").step_out,                      { desc = "Step out" } },
	{ "n", "<leader>dj",       require("dap").down,                          { desc = "Go down stack frame" } },
	{ "n", "<leader>dk",       require("dap").up,                            { desc = "Go up stack frame" } },

	-- git
	{ "n", "<leader>n",        ":Neogit<CR>",                                { desc = "[N]eogit" } },

	-- file tree
	{ "n", "<leader>e",        ":NvimTreeToggle<CR>",                        { desc = "Open Tree [E]xplorer" } },

	-- flash
	{ "n", "s",                function() require("flash").jump() end,        { desc = "Flash jump" } },
	{ "n", "S",                function() require("flash").treesitter() end,  { desc = "Flash treesitter" } },

	-- trouble
	{ "n", "<leader>xx",       "<cmd>Trouble diagnostics toggle<cr>",        { desc = "Diagnostics" } },
	{ "n", "<leader>xb",       "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" } },
	{ "n", "<leader>xs",       "<cmd>Trouble symbols toggle<cr>",            { desc = "Symbols" } },
	{ "n", "<leader>xl",       "<cmd>Trouble lsp toggle<cr>",                { desc = "LSP definitions / references" } },

	-- todo-comments
	{ "n", "<leader>sq",       "<cmd>TodoTelescope<cr>",                     { desc = "[S]earch [T]odo comments" } },
	{ "n", "]t",               function() require("todo-comments").jump_next() end, { desc = "Next todo" } },
	{ "n", "[t",               function() require("todo-comments").jump_prev() end, { desc = "Prev todo" } },

	-- persistence
	{ "n", "<leader>ps",       function() require("persistence").load() end,               { desc = "[P]ersistence load [S]ession" } },
	{ "n", "<leader>pl",       function() require("persistence").load({ last = true }) end, { desc = "[P]ersistence [L]ast session" } },
	{ "n", "<leader>px",       function() require("persistence").stop() end,               { desc = "[P]ersistence stop" } },

	-- AI
	{ "n", "<leader>id", function()
		if vim.bo.filetype ~= "cs" then
			vim.notify("Only works in C# files", vim.log.levels.WARN)
			return
		end
		require("avante.api").ask({
			question = "Add C# XML <summary> documentation comments to all public classes, methods, and properties that are missing XML documentation. Only add /// <summary>...</summary> doc comment blocks immediately above each undocumented public member. Do not modify any existing code or existing documentation.",
		})
	end, { desc = "[I]AI [D]ocument C# public members" } },

	-- harpoon
	{ "n", "<leader>a",        function() harpoon:list():add() end,                        { desc = "Harpoon add file" } },
	{ "n", "<C-e>",            function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" } },
	{ "n", "<leader>1",        function() harpoon:list():select(1) end,                    { desc = "Harpoon file 1" } },
	{ "n", "<leader>2",        function() harpoon:list():select(2) end,                    { desc = "Harpoon file 2" } },
	{ "n", "<leader>3",        function() harpoon:list():select(3) end,                    { desc = "Harpoon file 3" } },
	{ "n", "<leader>4",        function() harpoon:list():select(4) end,                    { desc = "Harpoon file 4" } },

}

for _, map in ipairs(keymaps) do
	vim.keymap.set(map[1], map[2], map[3], map[4])
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Autocmds
-- ─────────────────────────────────────────────────────────────────────────────

-- Close diffview with 'q'
vim.api.nvim_create_autocmd("FileType", {
	pattern  = "DiffviewFiles",
	callback = function()
		vim.keymap.set("n", "q", function()
			vim.cmd("DiffviewClose")
			vim.cmd("qa")
		end, { buffer = true })
	end,
})

-- Auto-insert namespace when creating a new C# file
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern  = "*.cs",
	callback = function() vim.cmd("EasyDotnetNamespace") end,
})

-- Show signature help when holding cursor in insert mode
vim.api.nvim_create_autocmd("CursorHoldI", {
	callback = function() vim.lsp.buf.signature_help() end,
})

-- Build Avante after install/update
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name = ev.data.spec.name
		local kind = ev.data.kind
		if name == "avante.nvim" and (kind == "install" or kind == "update") then
			vim.system({ "make" }, { cwd = ev.data.path }):wait()
		end
	end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- WezTerm integration — send Neovim mode to tab bar status indicator
-- ─────────────────────────────────────────────────────────────────────────────
local function set_wezterm_mode(mode)
	local pane_id = vim.env.WEZTERM_PANE
	if not pane_id then return end
	local tmp = os.getenv("TEMP") or os.getenv("TMP") or "C:\\Temp"
	local path = tmp .. "\\wezterm_nvim_" .. pane_id .. ".mode"
	local f = io.open(path, "w")
	if f then
		f:write(mode)
		f:close()
	end
end

vim.api.nvim_create_autocmd("ModeChanged", {
	pattern  = "*",
	callback = function() set_wezterm_mode(vim.fn.mode()) end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	callback = function() set_wezterm_mode("") end,
})

-- ─────────────────────────────────────────────────────────────────────────────
-- Colorscheme
-- ─────────────────────────────────────────────────────────────────────────────
vim.cmd("colorscheme catppuccin")
