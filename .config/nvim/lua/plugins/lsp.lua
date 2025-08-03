return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            --    single_file_support = true,
            --require("lspconfig").clangd.setup {
            --}
            require("lspconfig").clangd.setup {
                -- https://github.com/p00f/clangd_extensions.nvim
                cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
                init_options = {
                    fallbackFlags = { '-std=c++17', '-DRDIPF_lnx64' },
                },
                on_attach = function(_, buf) 
                    -- force the sign column to stay open for icons
                    -- https://neovim.discourse.group/t/can-i-force-the-diagnostics-gutter-to-stay-open/1269/4
                    vim.opt.signcolumn = "yes"
                end
            }
        end,
    }
}
