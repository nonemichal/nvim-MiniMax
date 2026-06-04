local ensure_installed = {}

local servers = {
	["arduino-language-server"] = {},
	["asm-lsp"] = {},
	["basedpyright"] = {},
	["bash-language-server"] = {},
	["basics-language-server"] = {},
	["clangd"] = {},
	["docker-language-server"] = {},
	["fish-lsp"] = {},
	["gh-actions-language-server"] = {},
	["glsl_analyzer"] = {},
	["haskell-language-server"] = {},
	["html-lsp"] = {},
	["htmx-lsp"] = {},
	["json-lsp"] = {},
	["language-server-bitbake"] = {},
	["lua-language-server"] = {},
	["marksman"] = {},
	["neocmakelsp"] = {},
	["rust-analyzer"] = {},
	["systemd-lsp"] = {},
	["taplo"] = {},
	["tinymist"] = {},
	["typescript-language-server"] = {},
	["typos-lsp"] = {},
	["wasm-language-tools"] = {},
	["yaml-language-server"] = {},
}
for name, _ in pairs(servers) do
	table.insert(ensure_installed, name)
end

local linters = {
	"actionlint",
	"checkmake",
	"cmakelint",
	"codespell",
	"cpplint",
	"gitleaks",
	"gitlint",
	"hadolint",
	"hlint",
	"htmlhint",
	"jsonlint",
	"luacheck",
	"markdownlint",
	"oelint-adv",
	"ruff",
	"shellcheck",
	"systemdlint",
	"yamllint",
}
vim.list_extend(ensure_installed, linters)

local formatters = {
	-- c = {'clangd'},
	-- cpp = {'clangd'},
	asm = { "asmfmt" },
	cmake = { "gersemi" },
	glsl = { "glsl_analyzer" },
	haskell = { "ormolu" },
	html = { "htmlbeautifier" },
	json = { "fixjson" },
	lua = { "stylua" },
	markdown = { "markdownlint" },
	python = { "ruff" },
	sh = { "beautysh" },
	toml = { "taplo" },
	wasm = { "wasm-language-tools" },
	yaml = { "yamlfmt" },
}
for _, tools in pairs(formatters) do
	vim.list_extend(ensure_installed, tools)
end

local daps = {
	-- ['haskell-debug-adapter'] = {},
	["bash-debug-adapter"] = {},
	["codelldb"] = {},
	["cortex-debug"] = {},
	["debugpy"] = {},
	["js-debug-adapter"] = {},
	["local-lua-debugger-vscode"] = {},
}
for name, _ in pairs(daps) do
	table.insert(ensure_installed, name)
end

return ensure_installed
