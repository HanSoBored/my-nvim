local map = vim.keymap.set

-- General
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>h", "<cmd>nohl<cr>", { desc = "No Highlight" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Rust specific (with manual trigger)
map("n", "<leader>rs", "<cmd>RustLsp start<cr>", { desc = "🦀 Start rust-analyzer (Manual)" })
map("n", "<leader>rS", "<cmd>RustLsp stop<cr>", { desc = "🛑 Stop rust-analyzer" })
map("n", "<leader>r?", "<cmd>lua print('Check rust-analyzer status')<cr>", { desc = "Check rust-analyzer status" })
map("n", "<leader>rr", "<cmd>RustRun<cr>", { desc = "Rust Run" })
map("n", "<leader>rt", "<cmd>RustTest<cr>", { desc = "Rust Test" })
map("n", "<leader>rc", "<cmd>RustCheck<cr>", { desc = "Rust Check" })
map("n", "<leader>rb", "<cmd>CargoBuild<cr>", { desc = "Cargo Build" })