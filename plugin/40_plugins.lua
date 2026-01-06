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
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

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
now_if_args(function()
  add {
    source = 'nvim-treesitter/nvim-treesitter',
    -- Update tree-sitter parser after plugin is updated
    hooks = {
      post_checkout = function()
        vim.cmd 'TSUpdate'
      end,
    },
  }
  add {
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    -- Use `main` branch since `master` branch is frozen, yet still default
    -- It is needed for compatibility with 'nvim-treesitter' `main` branch
    checkout = 'main',
  }

  -- Define languages which will have parsers installed and auto enabled
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
    'arduino',
    'asm',
    'bash',
    'bibtex',
    'bitbake',
    'c',
    'cmake',
    'comment',
    'cpp',
    'css',
    'csv',
    'desktop',
    'devicetree',
    'disassembly',
    'dockerfile',
    'doxygen',
    'fish',
    'git_config',
    'git_rebase',
    'gitattributes',
    'gitcommit',
    'gitignore',
    'glsl',
    'haskell',
    'html',
    'http',
    'hyprlang',
    'json',
    'kconfig',
    'latex',
    'llvm',
    'luadoc',
    'make',
    'matlab',
    'nasm',
    'objc',
    'objdump',
    'powershell',
    'python',
    'qmldir',
    'qmljs',
    'regex',
    'requirements',
    'rust',
    'ssh_config',
    'toml',
    'udev',
    'vim',
    'yaml',
    'zsh',
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then
    require('nvim-treesitter').install(to_install)
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
  _G.Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
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
  add 'neovim/nvim-lspconfig'

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
  add 'stevearc/conform.nvim'

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup {
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    -- formatters_by_ft = { lua = { 'stylua' } },
  }
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
  add 'rafamadriz/friendly-snippets'
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
  add 'mason-org/mason.nvim'
  add 'mason-org/mason-lspconfig.nvim'
  add 'WhoIsSethDaniel/mason-tool-installer.nvim'
  -- add('j-hui/fidget.nvim')
  -- add('saghen/blink.cmp')
  require('mason').setup()

  local ensure_installed = require 'ensure-installed'
  require('mason-tool-installer').setup { ensure_installed = ensure_installed, run_on_start = true }

  require('mason-lspconfig').setup {
    ensure_installed = {},
    automatic_installation = false,
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }
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

MiniDeps.now(function()
  add 'sainnhe/gruvbox-material'
  vim.g.gruvbox_material_background = 'soft'
  vim.g.gruvbox_material_enable_italic = false
  vim.g.gruvbox_material_foreground = 'material'
  vim.g.gruvbox_material_better_performance = 1
  vim.cmd 'color gruvbox-material'
end)

now_if_args(function()
  add {
    source = 'stevearc/oil.nvim',
    depends = {
      'echasnovski/mini.icons',
    },
  }

  require('oil').setup {
    columns = { 'icon', 'permissions', 'size', 'mtime' },
    win_options = {
      wrap = true,
      signcolumn = 'yes',
    },
    view_options = {
      show_hidden = true,
    },
  }
  vim.keymap.set('n', '<leader>ee', '<cmd>Oil<CR>', { desc = 'Open Oil' })
end)

now_if_args(function()
  add { source = 'benomahony/oil-git.nvim', depends = { 'stevearc/oil.nvim' } }
end)

now_if_args(function()
  add { source = 'max397574/better-escape.nvim' }
end)

now_if_args(function()
  add { source = 'RaafatTurki/hex.nvim' }
end)

now_if_args(function()
  add { source = 'fei6409/log-highlight.nvim' }
end)

now_if_args(function()
  add { source = 'sQVe/sort.nvim' }
end)

now_if_args(function()
  add {
    source = 'mfussenegger/nvim-dap',
    depends = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
  }

  vim.keymap.set('n', '<F5>', function()
    require('dap').continue()
  end, { desc = 'Debug: Start/Continue' })

  vim.keymap.set('n', '<F1>', function()
    require('dap').step_into()
  end, { desc = 'Debug: Step Into' })

  vim.keymap.set('n', '<F2>', function()
    require('dap').step_over()
  end, { desc = 'Debug: Step Over' })

  vim.keymap.set('n', '<F3>', function()
    require('dap').step_out()
  end, { desc = 'Debug: Step Out' })

  vim.keymap.set('n', '<leader>b', function()
    require('dap').toggle_breakpoint()
  end, { desc = 'Debug: Toggle Breakpoint' })

  vim.keymap.set('n', '<leader>B', function()
    require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, { desc = 'Debug: Set Breakpoint' })

  vim.keymap.set('n', '<F7>', function()
    require('dapui').toggle()
  end, { desc = 'Debug: See last session result.' })

  local dap = require 'dap'
  local dapui = require 'dapui'

  require('mason-nvim-dap').setup {
    automatic_installation = true,
  }

  dapui.setup {
    icons = {
      expanded = '▾',
      collapsed = '▸',
      current_frame = '*',
    },
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = 'b',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
  }

  dap.listeners.after.event_initialized['dapui_config'] = dapui.open
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close
end)

now_if_args(function()
  add {
    source = 'mfussenegger/nvim-lint',
  }

  local lint = require 'lint'

  -- Define linters for each filetype
  lint.linters_by_ft = {
    asm = { 'asmfmt' },
    bash = { 'shellcheck', 'shfmt' },
    bitbake = { 'oelint-adv' },
    c = { 'cpplint' },
    cmake = { 'cmake_lint' },
    cpp = { 'cpplint' },
    docker = { 'hadolint' },
    fish = { 'fish' },
    git = { 'gitlint' },
    hadolint = { 'hadolint' },
    html = { 'htmlhint' },
    json = { 'jsonlint' },
    lua = { 'luacheck' },
    makefile = { 'checkmake' },
    markdown = { 'markdownlint' },
    python = { 'ruff' },
    systemd = { 'systemdlint' },
    webassembly = { 'wasm-language-tools' },
    yaml = { 'yamllint', 'actionlint' },
  }

  -- Lint on save
  vim.api.nvim_create_autocmd('BufWritePost', {
    callback = function()
      -- Run linters defined for the current filetype
      lint.try_lint()

      -- Always run codespell
      lint.try_lint 'codespell'
    end,
  })
end)
