vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Rust optimized options
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10

-- Clipboard configuration
-- Coba berbagai provider clipboard
local function setup_clipboard()
  -- Check OS
  local uname = vim.loop.os_uname().sysname
  
  if uname == "Darwin" then
    -- macOS
    vim.g.clipboard = {
      name = 'pbcopy',
      copy = {
        ['+'] = 'pbcopy',
        ['*'] = 'pbcopy',
      },
      paste = {
        ['+'] = 'pbpaste',
        ['*'] = 'pbpaste',
      },
      cache_enabled = 0,
    }
  elseif uname == "Linux" then
    -- Check if running under WSL
    local f = io.open("/proc/version", "r")
    if f then
      local version = f:read("*all")
      f:close()
      if version:match("Microsoft") or version:match("WSL") then
        -- WSL - gunakan clip.exe atau powershell
        vim.g.clipboard = {
          name = 'WslClipboard',
          copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
          },
          paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          },
          cache_enabled = 0,
        }
      else
        -- Linux native - coba xclip, xsel, atau wl-copy
        local clipboard_tool = nil
        local paste_tool = nil
        
        -- Check which tool is available
        if vim.fn.executable("xclip") == 1 then
          clipboard_tool = "xclip -selection clipboard"
          paste_tool = "xclip -selection clipboard -o"
        elseif vim.fn.executable("xsel") == 1 then
          clipboard_tool = "xsel --clipboard --input"
          paste_tool = "xsel --clipboard --output"
        elseif vim.fn.executable("wl-copy") == 1 then
          clipboard_tool = "wl-copy"
          paste_tool = "wl-paste"
        end
        
        if clipboard_tool then
          vim.g.clipboard = {
            name = 'LinuxClipboard',
            copy = {
              ['+'] = clipboard_tool,
              ['*'] = clipboard_tool,
            },
            paste = {
              ['+'] = paste_tool,
              ['*'] = paste_tool,
            },
            cache_enabled = 0,
          }
        end
      end
    end
  elseif uname:match("Windows") then
    -- Windows native
    vim.g.clipboard = {
      name = 'win32yank',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = 0,
    }
  end
end

setup_clipboard()

-- Fallback: gunakan vim internal jika clipboard masih tidak ada
vim.opt.clipboard = "unnamedplus"

-- Function untuk copy dengan berbagai metode
function CopyToClipboard(text)
  -- Coba clipboard provider
  local has_clipboard = vim.fn.has('clipboard') == 1
  
  if has_clipboard and vim.g.clipboard then
    vim.fn.setreg('+', text)
    vim.notify("📋 Copied to clipboard", vim.log.levels.INFO)
    return true
  end
  
  -- Fallback: copy ke file temporary
  local temp_file = vim.fn.stdpath('cache') .. '/nvim_copy_buffer.txt'
  local f = io.open(temp_file, 'w')
  if f then
    f:write(text)
    f:close()
    
    -- Coba copy dengan system command
    local cmd = nil
    if vim.fn.executable("xclip") == 1 then
      cmd = "cat " .. temp_file .. " | xclip -selection clipboard"
    elseif vim.fn.executable("xsel") == 1 then
      cmd = "cat " .. temp_file .. " | xsel --clipboard --input"
    elseif vim.fn.executable("wl-copy") == 1 then
      cmd = "cat " .. temp_file .. " | wl-copy"
    elseif vim.fn.executable("pbcopy") == 1 then
      cmd = "cat " .. temp_file .. " | pbcopy"
    elseif vim.fn.executable("clip.exe") == 1 then
      cmd = "cat " .. temp_file .. " | clip.exe"
    end
    
    if cmd then
      os.execute(cmd)
      vim.notify("📋 Copied to clipboard (via file)", vim.log.levels.INFO)
      return true
    else
      -- Buka file untuk manual copy
      vim.cmd("vsplit " .. temp_file)
      vim.notify("⚠️ Clipboard not available. Text saved to: " .. temp_file, vim.log.levels.WARN)
      return false
    end
  end
  
  vim.notify("❌ Failed to copy", vim.log.levels.ERROR)
  return false
end

-- Test clipboard saat startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local has_clipboard = vim.fn.has('clipboard') == 1
    if not has_clipboard then
      vim.defer_fn(function()
        vim.notify("⚠️ Clipboard not detected. Install xclip/xsel/wl-clipboard", vim.log.levels.WARN)
      end, 1000)
    end
  end,
})

-- Log LSP dan error ke file
vim.lsp.set_log_level("debug")

-- Fungsi untuk copy error ke clipboard (updated)
vim.api.nvim_create_user_command("CopyLastError", function()
  local messages = vim.fn.execute("messages")
  local lines = vim.split(messages, "\n")
  
  -- Cari line error terakhir
  for i = #lines, 1, -1 do
    local line = lines[i]
    if line:match("Error") or line:match("error:") or line:match("E%d+") then
      CopyToClipboard(line)
      return
    end
  end
  
  vim.notify("❌ No error found in messages", vim.log.levels.WARN)
end, {})

-- Keymap untuk copy error
vim.keymap.set("n", "<leader>ce", "<cmd>CopyLastError<cr>", { desc = "Copy Last Error" })

-- Lihat full messages di buffer baru
vim.api.nvim_create_user_command("Messages", function()
  local messages = vim.fn.execute("messages")
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages, "\n"))
  vim.bo.modifiable = false
  vim.bo.buflisted = false
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "log"
  vim.cmd("setlocal wrap")
end, {})

vim.keymap.set("n", "<leader>cm", "<cmd>Messages<cr>", { desc = "View Full Messages" })

-- Cek status clipboard
vim.api.nvim_create_user_command("CheckClipboard", function()
  local has_clipboard = vim.fn.has('clipboard')
  local clipboard_provider = vim.g.clipboard and vim.g.clipboard.name or "none"
  
  print("=== Clipboard Status ===")
  print("has('clipboard'): " .. has_clipboard)
  print("Provider: " .. clipboard_provider)
  print("vim.opt.clipboard: " .. vim.inspect(vim.opt.clipboard:get()))
  
  -- Test copy
  local test_text = "Test clipboard " .. os.time()
  local success = pcall(function()
    vim.fn.setreg('+', test_text)
    local read_back = vim.fn.getreg('+')
    return read_back == test_text
  end)
  
  if success then
    print("✅ Clipboard working!")
  else
    print("❌ Clipboard not working")
    print("\nInstall one of these:")
    print("  - xclip (sudo apt install xclip)")
    print("  - xsel (sudo apt install xsel)")
    print("  - wl-clipboard (sudo apt install wl-clipboard)")
  end
end, {})

vim.keymap.set("n", "<leader>vc", "<cmd>CheckClipboard<cr>", { desc = "Check Clipboard Status" })