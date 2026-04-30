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

  local conform = require 'conform'

  conform.setup {
    formatters = {
      glsl_analyzer = {
        command = 'glsl_analyzer',
        args = { '--format', '$FILENAME' },
        stdin = false,
      },
      wat_server = {
        command = 'wat_server',
        args = { '--format', '$FILENAME' },
        stdin = false,
      },
    },

    formatters_by_ft = {
      asm = { 'asmfmt' },
      lua = { 'stylua' },
      python = { 'ruff_format', 'ruff_fix', 'ruff_organize_imports' },
      cmake = { 'gersemi' },
      markdown = { 'markdownlint' },
      sh = { 'beautysh' },
      yaml = { 'yamlfmt' },
      toml = { 'taplo' },
      html = { 'htmlbeautifier' },
      json = { 'fixjson' },
      haskell = { 'ormolu' },

      -- added:
      -- glsl = { 'glsl_analyzer' },
      -- wat = { 'wat_server' },
      -- c = { 'clangd' },
      -- cpp = { 'clangd' },
    },
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
  add {
    source = 'RaafatTurki/hex.nvim',
  }
  require('hex').setup()
end)

now_if_args(function()
  add { source = 'fei6409/log-highlight.nvim' }
end)

now_if_args(function()
  add { source = 'sQVe/sort.nvim' }
  require('sort').setup()
end)

now_if_args(function()
  add {
    source = 'esmuellert/codediff.nvim',
    depends = { 'MunifTanjim/nui.nvim' },
  }
end)

now_if_args(function()
  add {
    source = 'https://codeberg.org/esensar/nvim-dev-container',
    depends = { 'nvim-treesitter/nvim-treesitter' },
  }
  require('devcontainer').setup {}
end)

now_if_args(function()
  add { source = 'max397574/better-escape.nvim' }
  require('better_escape').setup {}
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

  local dap = require 'dap'
  local dapui = require 'dapui'

  -- Track DAP UI state manually
  local dapui_open = false

  -- Wrapper for toggling DAP UI and adjusting signcolumn
  local function toggle_dapui_and_signcolumn()
    if dapui_open then
      dapui.close()
      vim.wo.signcolumn = 'yes' -- revert to single column
      dapui_open = false
    else
      dapui.open()
      vim.wo.signcolumn = 'yes:2' -- use 2 columns when UI is open
      dapui_open = true
    end
  end

  -- Helper function to map both <Fx> and <leader>d<Fx>
  local function map_dap(key, fn, desc)
    vim.keymap.set('n', key, fn, { desc = desc })
    vim.keymap.set('n', '<leader>d' .. key, fn, { desc = desc })
  end

  -- Debug control(function keys + leader variants)
  map_dap('<F5>', dap.continue, 'Start/Continue')
  map_dap('<F1>', dap.step_into, 'Step Into')
  map_dap('<F2>', dap.step_over, 'Step Over')
  map_dap('<F3>', dap.step_out, 'Step Out')

  -- Debug UI toggle
  map_dap('<F7>', toggle_dapui_and_signcolumn, 'Toggle UI')

  -- Breakpoint mappings (leader only)
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, {
    desc = 'Set Breakpoint',
  })
  vim.keymap.set('n', '<leader>dB', function()
    dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, {
    desc = 'Set Conditional Breakpoint',
  })

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
        pause = '‖',
        play = '▶',
        step_into = '↳',
        step_over = '↷',
        step_out = '↪',
        step_back = '←',
        run_last = '▶▶',
        terminate = '■',
        disconnect = '⏏',
      },
    },
  }

  -- Define DAP signs
  vim.fn.sign_define('DapBreakpoint', {
    text = '●',
    texthl = 'Error',
  })
  vim.fn.sign_define('DapBreakpointCondition', {
    text = '◆',
    texthl = 'DiagnosticWarn',
  })
  vim.fn.sign_define('DapBreakpointRejected', {
    text = '×',
    texthl = 'WarningMsg',
  })
  vim.fn.sign_define('DapStopped', {
    text = '→',
    texthl = 'DiagnosticInfo',
  })

  -- Open and close DAP UI automatically
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end
end)

now_if_args(function()
  add {
    source = 'igorlfs/nvim-dap-view',
    depends = { 'mfussenegger/nvim-dap' },
  }
end)

now_if_args(function()
  add {
    source = 'mfussenegger/nvim-lint',
  }

  local lint = require 'lint'

  -- Define linters for each filetype
  lint.linters_by_ft = {
    bash = { 'shellcheck' },
    bitbake = { 'oelint-adv' },
    c = { 'cpplint' },
    cmake = { 'cmakelint' },
    cpp = { 'cpplint' },
    docker = { 'hadolint' },
    git = { 'gitlint', 'gitleaks' },
    html = { 'htmlhint' },
    json = { 'jsonlint' },
    lua = { 'luacheck' },
    makefile = { 'checkmake' },
    markdown = { 'markdownlint' },
    python = { 'ruff' },
    systemd = { 'systemdlint' },
    webassembly = { 'wasm-language-tools' },
    yaml = { 'yamllint' },
  }

  -- Lint on save, on file open and when entering a buffer
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
    callback = function()
      -- Run linters defined for the current filetype
      lint.try_lint()

      -- Always run codespell
      lint.try_lint 'codespell'
    end,
  })
end)

now_if_args(function()
  add { source = 'akinsho/toggleterm.nvim' }

  require('toggleterm').setup {
    size = 20,
    open_mapping = nil,
    close_on_exit = true,
    float_opts = {
      border = 'rounded',
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
      winblend = 3,
      zindex = 50,
      row = math.floor(vim.o.lines * 0.1),
      col = math.floor(vim.o.columns * 0.1),
      title_pos = 'center',
    },
  }

  local Terminal = require('toggleterm.terminal').Terminal
  local float_term = Terminal:new { direction = 'float' }

  vim.keymap.set('n', '<Leader>tf', function()
    float_term:toggle()
  end, { desc = 'Terminal (floating)' })

  vim.keymap.set('t', '<Esc>', function()
    float_term:toggle()
  end, { desc = 'Hide floating terminal' })

  vim.keymap.set('n', '<Esc>', function()
    local bufnr = vim.api.nvim_get_current_buf()
    if float_term.bufnr == bufnr then
      float_term:toggle()
    end
  end, { desc = 'Hide floating terminal in normal mode' })
end)

now_if_args(function()
  add {
    source = 'nemanjamalesija/smart-paste.nvim',
  }
  require('smart-paste').setup()
end)

now_if_args(function()
  add {
    source = 'johmsalas/text-case.nvim',
  }
  require('textcase').setup()
end)
