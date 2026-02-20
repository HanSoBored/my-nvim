vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Performance
vim.opt.lazyredraw = false  -- Disabled: conflicts with Noice
vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.colorcolumn = "80,120"
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false  -- Use tabs in C
vim.opt.smartindent = true
vim.opt.cindent = true

-- Search
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Enable mouse
vim.opt.mouse = "a"

-- Enable 24-bit RGB color
vim.opt.termguicolors = true

-- C-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "h", "hpp" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
    vim.opt_local.cindent = true
    vim.opt_local.commentstring = "/* %s */"
  end,
})
