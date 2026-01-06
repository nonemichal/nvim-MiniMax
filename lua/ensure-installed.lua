local ensure_installed = {}

local servers = {
  ['arduino-language-server'] = {},
  ['asm-lsp'] = {},
  ['bash-language-server'] = {},
  ['basedpyright'] = {},
  ['basics-language-server'] = {},
  ['clangd'] = {},
  ['cmake-language-server'] = {},
  ['docker-compose-language-service'] = {},
  ['dockerfile-language-server'] = {},
  ['fish-lsp'] = {},
  ['gh-actions-language-server'] = {},
  ['glsl_analyzer'] = {},
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
  ['yamlls'] = {},
  ['wasm-language-tools'] = {},
  ['yaml-language-server'] = {},
}
for name, _ in pairs(servers) do
  table.insert(ensure_installed, name)
end

local linters = {
  'actionlint',
  'asmfmt',
  'checkmake',
  'cmakelang',
  'codespell',
  'cpplint',
  'gitleaks',
  'gitlint',
  'hadolint',
  'htmlhint',
  'jsonlint',
  'luacheck',
  'markdownlint',
  'oelint-adv',
  'ruff',
  'shellcheck',
  'shfmt',
  'stylua',
  'systemdlint',
  'yamlfmt',
  'yamllint',
  'qmlls',
}
vim.list_extend(ensure_installed, linters)

local formatters = {
  lua = { 'stylua' },
  python = { 'ruff' },
  cmake = { 'cmakelang' },
  markdown = { 'markdownlint' },
  sh = { 'shfmt' },
  wasm = { 'wasm-language-tools' },
  yaml = { 'yamlfmt' },
  toml = { 'taplo' },
  html = { 'htmlbeautifier' },
  glsl = { 'glsl_analyzer' },
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
}
for name, _ in pairs(daps) do
  table.insert(ensure_installed, name)
end

return ensure_installed
