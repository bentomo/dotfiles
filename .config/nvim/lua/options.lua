-- Cleanup these dirs on reinstall in addition to the ~/.config/nvim dir
-- ~/.local/share/nvim
-- ~/.local/state/nvim
-- ~/.cache/nvim
-- remaps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- OSC 52 clipboard — writes directly to the outer terminal TTY via osc52.sh,
-- bypassing tmux's set-clipboard/Ms re-emit path which depends on terminfo
-- and option scopes that proved unreliable across RHEL/tmux versions.
-- Paste falls back to internal register; use Ctrl+Shift+V in WezTerm to paste.
local osc52_script = os.getenv('HOME') .. '/.config/tmux/osc52.sh'
local function osc52_copy(lines, _)
  vim.fn.system(osc52_script, table.concat(lines, '\n'))
end
vim.g.clipboard = {
  name = 'osc52-tty',
  copy = {
    ['+'] = osc52_copy,
    ['*'] = osc52_copy,
  },
  paste = {
    ['+'] = function()
      return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
    end,
    ['*'] = function()
      return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
    end,
  },
}
vim.opt.clipboard:append({ 'unnamedplus' })

--true color
vim.o.termguicolors = true

-- quick jumps
vim.keymap.set("n", "<leader>j", "20j")
vim.keymap.set("n", "<leader>k", "20k")
vim.keymap.set("v", "<leader>j", "20j")
vim.keymap.set("v", "<leader>k", "20k")

-- explicit register copies (both land in OSC 52 → Windows clipboard)
vim.keymap.set("v", "<leader>c", "\"*y")
vim.keymap.set({"n","v"}, "<leader>P", "\"*p")

-- swap $ and 0 because that's backwards
vim.keymap.set({"n","v"}, "$", "0")
vim.keymap.set({"n","v"}, "0", "$")

-- this lets you move lines up and down with shift+j/k in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

--fix visual block mode so you can select non matching lines
vim.opt.virtualedit = "block"

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- allow command completion on lowercase commands
vim.opt.ignorecase = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "split" --show preview of global updates in lower window

vim.opt.termguicolors = true

vim.opt.scrolloff = 999

-- need to look up what this does for settings
local opts = { noremap = true, silent = true }
-- Stay in indent mode when adjusting indentation
vim.keymap.set("v", "<", "<gv^", opts)
vim.keymap.set("v", ">", ">gv^", opts)

-- Navigate buffers faster
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)

-- paste into system buffer with <leader>y - needs some testing with xsel
--vim.keymap.set("n", "<leader>y", "\"+y")
--vim.keymap.set("n", "<leader>Y", "\"+Y")
--vim.keymap.set("v", "<leader>y", "\"+y")

-- when pasting don't lose paste buffer
vim.keymap.set("x", "<leader>p", "\"_dP")
-- prevent deleting into paste register
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- add in quick fix navigation
-- vim.keymap.set("n", "<C-k>", "<cmd>cnest<CR>zz")
-- etc

-- find and replace word that you're on
vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- lsp option to display virtualtext
-- TODO - add a repeat dot command https://www.reddit.com/r/neovim/comments/1cgxt0x/comment/l1ywi1j/?context=3&share_id=t1d3KTe-KFM3HFu17cnQd&utm_content=1&utm_medium=ios_app&utm_name=ioscss&utm_source=share&utm_term=1
vim.keymap.set("n", "<leader>ls", "<cmd> lua vim.diagnostic.open_float() <CR>")
vim.keymap.set("n", "<leader>ln", "<cmd> lua vim.diagnostic.goto_next() <CR>")
vim.keymap.set("n", "<leader>lp", "<cmd> lua vim.diagnostic.goto_next() <CR>")

-- fix cindent for switch statements
vim.cmd("autocmd FileType c,cpp setlocal shiftwidth=2 tabstop=2 cindent expandtab")
vim.cmd("set cinoptions=:0,l1,g0,(0,W4,m1")
