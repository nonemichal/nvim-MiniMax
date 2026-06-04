-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
	-- Define hook to update tree-sitter parsers after plugin is updated
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	})

	-- Define languages which will have parsers installed and auto enabled
	local languages = {
		-- These are already pre-installed with Neovim. Used as an example.
		"arduino",
		"asm",
		"bash",
		"bibtex",
		"bitbake",
		"c",
		"cmake",
		"comment",
		"cpp",
		"css",
		"csv",
		"desktop",
		"devicetree",
		"disassembly",
		"dockerfile",
		"doxygen",
		"fish",
		"git_config",
		"git_rebase",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"glsl",
		"haskell",
		"html",
		"http",
		"hyprlang",
		"json",
		"kconfig",
		"latex",
		"llvm",
		"lua",
		"luadoc",
		"make",
		"markdown",
		"matlab",
		"nasm",
		"objc",
		"objdump",
		"powershell",
		"python",
		"qmldir",
		"qmljs",
		"regex",
		"requirements",
		"rust",
		"ssh_config",
		"toml",
		"typst",
		"udev",
		"vim",
		"vimdoc",
		"yaml",
		"zsh",
		-- Add here more languages with which you want to use tree-sitter
		-- To see available languages:
		-- - Execute `:=require('nvim-treesitter').get_available()`
		-- - Visit 'SUPPORTED_LANGUAGES.md' file at
		--   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	_G.Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
	add({ "https://github.com/neovim/nvim-lspconfig" })

	-- Use `:h vim.lsp.enable()` to automatically enable language server based on
	-- the rules provided by 'nvim-lspconfig'.
	-- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
	-- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
	-- vim.lsp.enable({
	--   -- For example, if `lua-language-server` is installed, use `'lua_ls'` entry
	-- })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
	add({ "https://github.com/stevearc/conform.nvim" })

	local conform = require("conform")

	conform.setup({
		formatters = {
			glsl_analyzer = {
				command = "glsl_analyzer",
				args = { "--format", "$FILENAME" },
				stdin = false,
			},
			wat_server = {
				command = "wat_server",
				args = { "--format", "$FILENAME" },
				stdin = false,
			},
		},

		formatters_by_ft = {
			asm = { "asmfmt" },
			lua = { "stylua" },
			python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
			cmake = { "gersemi" },
			markdown = { "markdownlint" },
			sh = { "beautysh" },
			yaml = { "yamlfmt" },
			toml = { "taplo" },
			html = { "htmlbeautifier" },
			json = { "fixjson" },
			haskell = { "ormolu" },

			-- added:
			-- glsl = { 'glsl_analyzer' },
			-- wat = { 'wat_server' },
			c = { "clang-format" },
			cpp = { "clang-format" },
		},
	})
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function()
	add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
now_if_args(function()
	add({
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	})
	require("mason").setup()

	local ensure_installed = require("ensure-installed")
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed, run_on_start = true })

	vim.lsp.enable({
		"arduino_language_server",
		"asm_lsp",
		"bashls",
		"dockerls",
		"fish_lsp",
		"gh_actions_ls",
		"glsl_analyzer",
		"hls",
		"html",
		"htmx",
		"jsonls",
		"lua_ls",
		"marksman",
		"neocmake",
		"rust_analyzer",
		"systemd_ls",
		"taplo",
		"tinymist",
		"ts_ls",
		"typos_lsp",
		"wasm_language_tools",
		"yamlls",
		"clangd",
		"basedpyright",
		"ruff",
	})
end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- MiniDeps.now(function()
--   -- Install only those that you need
--   add('sainnhe/everforest')
--   add('Shatur/neovim-ayu')
--   add('ellisonleao/gruvbox.nvim')
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)

now(function()
	add({ "https://github.com/sainnhe/gruvbox-material" })
	vim.g.gruvbox_material_background = "soft"
	vim.g.gruvbox_material_enable_italic = false
	vim.g.gruvbox_material_foreground = "material"
	vim.g.gruvbox_material_better_performance = 1
	vim.cmd("color gruvbox-material")
end)

now_if_args(function()
	add({
		"https://github.com/stevearc/oil.nvim",
		"https://github.com/echasnovski/mini.icons",
	})

	require("oil").setup({
		columns = { "icon", "permissions", "size", "mtime" },
		win_options = {
			wrap = true,
			signcolumn = "yes",
		},
		view_options = {
			show_hidden = true,
		},
	})
	vim.keymap.set("n", "<leader>ee", "<cmd>Oil<CR>", { desc = "Open Oil" })
end)

now_if_args(function()
	add({ "https://github.com/benomahony/oil-git.nvim", "https://github.com/stevearc/oil.nvim" })
end)

now_if_args(function()
	add({ "https://github.com/RaafatTurki/hex.nvim" })
	require("hex").setup()
end)

now_if_args(function()
	add({ "https://github.com/fei6409/log-highlight.nvim" })
end)

now_if_args(function()
	add({ "https://github.com/sQVe/sort.nvim" })
	require("sort").setup()
end)

now_if_args(function()
	add({
		"https://github.com/esmuellert/codediff.nvim",
		"https://github.com/MunifTanjim/nui.nvim",
	})
end)

now_if_args(function()
	add({
		"https://codeberg.org/esensar/nvim-dev-container",
		"https://github.com/nvim-treesitter/nvim-treesitter",
	})
	require("devcontainer").setup({})
end)

now_if_args(function()
	add({
		"https://github.com/mfussenegger/nvim-dap",
		"https://github.com/igorlfs/nvim-dap-view",
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/jay-babu/mason-nvim-dap.nvim",
		"https://github.com/thehamsta/nvim-dap-virtual-text",
		"https://codeberg.org/Jorenar/nvim-dap-disasm",
	})

	local dap = require("dap")
	local dapview = require("dap-view")

	local dapview_open = false

	local function toggle_dapview()
		dapview.toggle()

		dapview_open = not dapview_open

		if dapview_open then
			vim.wo.signcolumn = "yes:2"
		else
			vim.wo.signcolumn = "yes"
		end
	end

	local function map_dap(key, fn, desc)
		vim.keymap.set("n", key, fn, { desc = desc })
		vim.keymap.set("n", "<leader>d" .. key, fn, { desc = desc })
	end

	-- Debug control
	map_dap("<F5>", dap.continue, "Start/Continue")
	map_dap("<F1>", dap.step_into, "Step Into")
	map_dap("<F2>", dap.step_over, "Step Over")
	map_dap("<F3>", dap.step_out, "Step Out")

	-- UI
	map_dap("<F7>", toggle_dapview, "Toggle DAP View")

	-- Breakpoints
	vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {
		desc = "Set Breakpoint",
	})

	vim.keymap.set("n", "<leader>dB", function()
		dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	end, {
		desc = "Set Conditional Breakpoint",
	})

	require("mason-nvim-dap").setup({
		automatic_installation = true,
	})

	dapview.setup({
		auto_toggle = true,
	})

	-- DAP signs
	vim.fn.sign_define("DapBreakpoint", {
		text = "●",
		texthl = "Error",
	})

	vim.fn.sign_define("DapBreakpointCondition", {
		text = "◆",
		texthl = "DiagnosticWarn",
	})

	vim.fn.sign_define("DapBreakpointRejected", {
		text = "×",
		texthl = "WarningMsg",
	})

	vim.fn.sign_define("DapStopped", {
		text = "→",
		texthl = "DiagnosticInfo",
	})
end)

now_if_args(function()
	add({ "https://github.com/mfussenegger/nvim-lint" })

	local lint = require("lint")

	-- Define linters for each filetype
	lint.linters_by_ft = {
		bash = { "shellcheck" },
		bitbake = { "oelint-adv" },
		c = { "cpplint" },
		cmake = { "cmakelint" },
		cpp = { "cpplint" },
		docker = { "hadolint" },
		git = { "gitlint", "gitleaks" },
		html = { "htmlhint" },
		json = { "jsonlint" },
		lua = { "luacheck" },
		makefile = { "checkmake" },
		markdown = { "markdownlint" },
		python = { "ruff" },
		systemd = { "systemdlint" },
		webassembly = { "wasm-language-tools" },
		yaml = { "yamllint" },
	}

	-- Lint on save, on file open and when entering a buffer
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
		callback = function()
			-- Run linters defined for the current filetype
			lint.try_lint()

			-- Always run codespell
			lint.try_lint("codespell")
		end,
	})
end)

now_if_args(function()
	add({ "https://github.com/nemanjamalesija/smart-paste.nvim" })
	require("smart-paste").setup()
end)

now_if_args(function()
	add({ "https://github.com/johmsalas/text-case.nvim" })
	require("textcase").setup()
end)

now_if_args(function()
	add({ "https://github.com/mfussenegger/nvim-dap-python" })
	require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
end)
