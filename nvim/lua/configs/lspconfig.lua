require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
        },
    },
})

vim.lsp.config("elixirls", {
    cmd = { "elixir-ls" },
    settings = {
        elixirLS = {
            dialyzerEnabled = true,
            fetchDeps = false,
        },
    },
})

vim.lsp.enable({
    "html",
    "cssls",
    "gopls",
    "clangd",
    "basedpyright",
    "elixirls",
})
