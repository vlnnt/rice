return {
    {
        "stevearc/conform.nvim",
        opts = require("configs.conform"),
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("configs.lspconfig")
        end,
    },
    {
        "FotiadisM/tabset.nvim",
        opts = {
            defaults = {
                tabwidth = 4,
                expandtab = true,
            },
        },
    },
    {
        "olexsmir/gopher.nvim",
        ft = "go",
        opts = {},

        build = function()
            vim.cmd("silent! GoInstallDeps")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            local languages = {
                "vim",
                "lua",
                "vimdoc",
                "html",
                "css",
            }

            for _, lang in ipairs(languages) do
                if not vim.tbl_contains(opts.ensure_installed, lang) then
                    table.insert(opts.ensure_installed, lang)
                end
            end
        end,
    },
}
