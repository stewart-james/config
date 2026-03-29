vim.o.number = true -- display line numbers
vim.o.relativenumber = true -- display relative line numbers
vim.o.signcolumn = "yes" -- always show the sign column
vim.o.wrap = false -- disable line wrapping
vim.o.tabstop = 4 -- a tab should LOOK like 4 characters
vim.o.softtabstop = 4 -- a tab should insert 1 tab ( equivilent of 4 spaces )
vim.o.shiftwidth = 4 -- a tab should insert 1 column ( equivilent of 4 spaces)
vim.o.expandtab = false -- use tabs not spaces
vim.o.autoindent = true -- automatically copy the indentation of the current line when starting a new line
vim.o.splitbelow = true -- ensure horizontal splits are opened below
vim.o.splitright = true -- ensure vertical splits are opened to the right
vim.o.swapfile = false -- disable creation of swapfiles
vim.o.title = true
vim.o.titlestring = [[%t – %{fnamemodify(getcwd(), ':t')}]]
vim.diagnostic.config({ virtual_text = { prefix = "●" } })
vim.o.clipboard = "unnamedplus"

vim.g.mapleader = " "

vim.pack.add({

	-- appearance
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },

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

	-- keymaps
	{ src = "https://github.com/folke/which-key.nvim" },

	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },

	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },
	{ src = "https://github.com/ray-x/lsp_signature.nvim" },

	-- Debug
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },

	-- Test
	--{ src = "https://github.com/nvim-neotest/nvim-nio"},
	--{ src = "https://github.com/nvim-neotest/neotest"},
	--{ src = "https://github.com/Issafalcon/neotest-dotnet"},

	-- C#
	--{ src = "https://github.com/seblyng/roslyn.nvim" },
	{ src = "https://github.com/GustavEikaas/easy-dotnet.nvim" },

	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },

	-- AI
	{ src = "https://github.com/zbirenbaum/copilot.lua" },
	{ src = "https://github.com/yetone/avante.nvim" },
})

--require('mason-lspconfig').setup()
require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})
require("mason-lspconfig").setup({
	ensure_installed = {
		--"●lua-language-server",
		-- "xmlformatter",
		-- "csharpier",
		-- "prettier",
		-- "stylua",
		--"html-lsp",
		--"css-lsp",
		--"eslint-lsp",
		--"json-lsp",
		--"roslyn", run manually :MasonInstall roslyn
	},
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"css",
		"c_sharp",
		"razor",
		"vim",
		"vimdoc",
		"query",
		"markdown",
		"markdown_inline",
		"xml",
		"html",
	},

	highlight = {
		enable = true,
	},
})

local function preview_diffview_file_under_cursor()
	local ok, lib = pcall(require, "diffview.lib")
	if not ok then
		return
	end

	local view = lib.get_current_view()
	if not view or not view.panel or not view.panel:is_focused() then
		return
	end

	-- false => do NOT allow directory nodes
	local file = view:infer_cur_file(false)
	if not file then
		return
	end

	-- focus=false keeps you in the file tree
	-- highlight=false avoids extra cursor jumping
	view:set_file(file, false, false)
end

require("diffview").setup({
	file_panel = {
		win_config = {
			width = 60,
		},
		indent_width = 1,
	},
	keymaps = {
		file_panel = {
			["j"] = function()
				vim.cmd.normal({ "j", bang = true })
				preview_diffview_file_under_cursor()
			end,
			["k"] = function()
				vim.cmd.normal({ "k", bang = true })
				preview_diffview_file_under_cursor()
			end,
			["<Down>"] = function()
				vim.cmd.normal({ "j", bang = true })
				preview_diffview_file_under_cursor()
			end,
			["<Up>"] = function()
				vim.cmd.normal({ "k", bang = true })
				preview_diffview_file_under_cursor()
			end,
		},
	},
})

-- Close neovim with 'q' when we are in diff mode
vim.api.nvim_create_autocmd("FileType", {
	pattern = "DiffviewFiles",
	callback = function()
		vim.keymap.set("n", "q", function()
			vim.cmd("DiffviewClose")
			vim.cmd("qa")
		end, { buffer = true })
	end,
})

require("lsp_signature").setup({
	hint_enable = true,
	floating_window = true,
})

-- local dap = require("dap")
-- local netcoredbg_adapter = {
-- 	type = "executable",
-- 	command = vim.fn.stdpath("data") .. "mason/packages/netcoredbg/netcoredbg",
-- 	args = { "--interpreter=vscode"},
-- }
--
-- dap.adapters.netcoredbg = netcoredbg_adapter
-- dap.adapters.coreclr = netcoredbg_adapter
-- dap.configurations.cs = {
-- 	{
-- 		type = "coreclr",
-- 		name = "launch - netcoredbg",
-- 		request = "launch", program = function()
-- 			return vim.fn.input("Path to dll:", vim.fn.getcwd() .. "/bin/Debug/net8.0", "file")
--
-- 		end,
-- 	},
-- }
--

local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Open UI automatically when debugging starts
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

-- Close UI automatically when debugging ends
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- require("neotest").setup({
-- 	adapters = {
-- 		require("neotest-dotnet")
-- 	}
-- })

--require('mason-tool-installer').setup({
--	ensure_installed = { "lua_ls", "csharpier", "lua-language-server", "xmlformatter", "stylua", "html-lsp", "css-lsp", "roslyn", "json-lsp" }
--})
require("nvim-tree").setup({ view = { width = 60 } })
require("easy-dotnet").setup({
	test_runner = {
		viewmode = "float",
		vsplit_width = nil,
		vsplit = "topright",
	},
	terminal = function(path, action, args)
		local commands = {
			run = function()
				return string.format("dotnet run --project %s %s", path, args)
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
			end,
		}

		local command = commands[action]() .. "\r"
		vim.cmd("split")
		vim.cmd("resize 30")
		vim.cmd("term " .. command)
	end,
})

-- keymaps
local groups = {
	{ "<leader>s", group = "[S]earch" },
	{ "<leader>l", group = "[L]anguage Server" },
	{ "<leader>c", group = "[C]lose" },
}

local keymaps = {
	-- general
	{
		"n",
		"<leader>o",
		":update<CR> :source<CR>",
		{ silent = true, desc = "Save and source file" },
	},
	{ "n", "<leader>w", ":write<CR>", { silent = true, desc = "Write file" } },
	{ "n", "<leader>q", ":quit<CR>", { silent = true, desc = "Quit" } },
	{ "n", "<leader>ct", ":tabclose<CR>", { desc = "[C]lose [T]ab" } },
	{ "n", "<leader><tab>", "<C-^>", { noremap = true } },

	-- search
	{ "n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" } },
	{ "n", "<leader>st", require("telescope.builtin").git_files, { desc = "[S]earch GitT] Files" } },
	{ "n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" } },
	{ "n", "<leader>sk", require("telescope.builtin").keymaps, { desc = "[S]earch [K]eymaps" } },
	{ "n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch [G]rep" } },
	{ "n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" } },
	{ "n", "<leader>sr", require("telescope.builtin").oldfiles, { desc = "[S]earch [R]ecent Files" } },
	{ "n", "<leader><leader>", require("telescope.builtin").buffers, { desc = "[ ]Search Buffers" } },

	-- language server
	{ "n", "<leader>lf", vim.lsp.buf.format, { desc = "LSP Format buffer" } },
	{ "n", "<leader>lh", vim.lsp.buf.hover, { desc = "LSP Hover" } },
	{ "n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to [D]efinition" } },
	{ "n", "<leader>li", vim.lsp.buf.implementation, { desc = "Go to [I]mplementation" } },
	{ "n", "<leader>lr", vim.lsp.buf.rename, { desc = "[R]ename" } },
	{ "n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code [A]ction" } },
	{ "n", "<leader>llr", vim.lsp.buf.references, { desc = "[L]ist [R]eferences" } },
	{ "n", "<leader>le", vim.diagnostic.open_float, { desc = "LSP [E]rror" } },

	-- dotnet stuff
	{ "n", "<leader>r", require("easy-dotnet").run, { desc = "[R]un" } },
	{ "n", "<leader>t", require("easy-dotnet").testrunner, { desc = "[T]est" } },
	{ "n", "<leader>c", require("easy-dotnet").clean, { desc = "[C]lean" } },
	--{ 'n', '<leader>b',        require("easy-dotnet").build,             { desc = "[B]uild" } },
	{ "n", "<leader>dbs", require("easy-dotnet").build_solution, { desc = "[D]otnet [B]uild [S]olution" } },
	{ "n", "<leader>dnr", require("easy-dotnet").restore, { desc = "[D]otnet [N]uget [R]estore" } },
	{ "n", "<leader>dts", require("easy-dotnet").test_solution, { desc = "[D]otnet [T]est [S]olution" } },
	{ "n", "<leader>dtr", require("easy-dotnet").testrunner, { desc = "[D]otnet [Test] [R]unner" } },

	-- debugger
	{ "n", "<leader>b", require("dap").toggle_breakpoint, { desc = "Toggle [B]reakpoint" } },
	{ "n", "<F5>", require("dap").continue, { desc = "Start/continue debugging" } },
	{ "n", "<F10>", require("dap").step_over, { desc = "Step over" } },
	{ "n", "<F11>", require("dap").step_into, { desc = "Step into" } },
	{ "n", "<F12>", require("dap").step_out, { desc = "Step out" } },
	{ "n", "<leader>dj", require("dap").down, { desc = "Go down stack frame" } },
	{ "n", "<leader>dk", require("dap").up, { desc = "Go up stack frame" } },

	-- git
	{ "n", "<leader>n", ":Neogit<CR>", { desc = "[N]eogit" } },

	-- file tree
	{ "n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Open Tree [E]xplorer" } },
}

for _, map in ipairs(keymaps) do
	vim.keymap.set(map[1], map[2], map[3], map[4])
end

require("which-key").add(groups)

require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"%.exe$",
			"%.dll$",
			"%.wdp$",
			"%.sys$",
			"%.rc$",
			"%.inf$",
			"%.png$",
		},
		path_display = function(_, path)
			local tail = require("telescope.utils").path_tail(path)
			local parts = vim.split(path, "\\")

			local display_parts = 3
			if #parts < display_parts then
				return path
			end

			return table.concat(vim.list_slice(parts, #parts - display_parts + 1, #parts), "/")
		end,
	},
})

require("render-markdown").setup({
	file_types = { "markdown", "Avante" },
})

-- Start Copilot backend used by Avante
require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

-- Avante config
require("avante").setup({
	provider = "copilot",
	-- keep this on something else unless you explicitly want Copilot autosuggestions here too
	-- auto_suggestions_provider = "copilot",
})

-- auto complete
vim.cmd("set completeopt+=noselect")
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.cs",
	callback = function()
		vim.cmd("EasyDotnetNamespace")
	end,
})

-- Show signature help when holding cursor in insert mode
vim.api.nvim_create_autocmd("CursorHoldI", {
	callback = function()
		vim.lsp.buf.signature_help()
	end,
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

vim.lsp.config("roslyn", {})

--vim.lsp.config["roslyn"] = {
--cmd = {
--		"dotnet",
--		"d:/tools/lsp/roslyn/content/LanguageServer/win-x64/Microsoft.CodeAnalysis.LanguageServer.dll",
--		"--logLevel=Information",
--		"--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
--		"--stdio",
--	},
--}
--vim.lsp.enable("roslyn")

local function set_wezterm_mode(mode)
	if vim.env.TERM_PROGRAM == "WezTerm" then
		io.write("\027]1337;SetUserVar=NVIM_MODE=" .. vim.base64.encode(mode) .. "\007")
		io.flush()
	end
end

vim.api.nvim_create_autocmd("ModeChanged", {
	pattern = "*",
	callback = function()
		set_wezterm_mode(vim.fn.mode())
	end,
})

vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		set_wezterm_mode("")
	end,
})

vim.cmd("colorscheme catppuccin")
