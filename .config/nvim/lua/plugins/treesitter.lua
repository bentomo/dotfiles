return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = {'c', 'lua', 'vim', 'vimdoc', 'query'}, --recommended install default by nvim
        auto_install = true,
        highlight = {
            enable = true,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<Leader>ss",
                node_incremental = "<Leader>si",
                scope_incremental = "<Leader>sc",
                node_decremental = "<Leader>sd",
            }
        },
    },
}
