local ensure_installed = {}

local servers = {
  ['arduino-language-server'] = {},
  ['asm-lsp'] = {},
  ['bash-language-server'] = {},
  ['basedpyright'] = {},
  ['basics-language-server'] = {},
  ['clangd'] = {},
  ['cmake-language-server'] = {},
  ['docker-language-server'] = {},
  ['fish-lsp'] = {},
  ['gh-actions-language-server'] = {},
  ['glsl_analyzer'] = {},
  ['hls'] = {},
  ['html-lsp'] = {},
  ['htmx-lsp'] = {},
  ['json-lsp'] = {},
  ['language-server-bitbake'] = {},
  ['lua-language-server'] = {},
  ['marksman'] = {},
  ['rust-analyzer'] = {},
  ['systemd-lsp'] = {},
  ['taplo'] = {},
  ['typescript-language-server'] = {},
  ['typos-lsp'] = {},
  ['wasm-language-tools'] = {},
  ['yaml-language-server'] = {},
}
for name, _ in pairs(servers) do
  table.insert(ensure_installed, name)
end

local linters = {
  'actionlint',
  'checkmake',
  'cmakelang',
  'codespell',
  'cpplint',
  'gitleaks',
  'gitlint',
  'hadolint',
  'hlint',
  'htmlhint',
  'jsonlint',
  'luacheck',
  'markdownlint',
  'oelint-adv',
  'ruff',
  'shellcheck',
  'systemdlint',
  'yamllint',
}
vim.list_extend(ensure_installed, linters)

local formatters = {
  asm = { 'asmfmt' },
  lua = { 'stylua' },
  python = { 'ruff' },
  cmake = { 'cmakelang' },
  markdown = { 'markdownlint' },
  sh = { 'beautysh' },
  wasm = { 'wasm-language-tools' },
  yaml = { 'yamlfmt' },
  toml = { 'taplo' },
  html = { 'htmlbeautifier' },
  glsl = { 'glsl_analyzer' },
  json = {'fixjson'},
  -- c = {'clangd'},
  -- cpp = {'clangd'},
  haskell = {'ormolu'},
}
for _, tools in pairs(formatters) do
  vim.list_extend(ensure_installed, tools)
end

local daps = {
  ['bash-debug-adapter'] = {},
  ['codelldb'] = {},
  ['cortex-debug'] = {},
  ['debugpy'] = {},
  ['js-debug-adapter'] = {},
  ['local-lua-debugger-vscode'] = {},
  -- ['haskell-debug-adapter'] = {},
}
for name, _ in pairs(daps) do
  table.insert(ensure_installed, name)
end

return ensure_installed
