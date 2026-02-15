return {
  -- Theme favorite for coding
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "terminal", "packer", "neotest-summary" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
      on_colors = function(colors)
        colors.bg = "#1a1b26"
        colors.bg_dark = "#16161e"
      end,
    },
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "nvim-tree", "lazy", "mason", "trouble", "toggleterm" },
    },
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = require("lazyvim.config").icons.diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
      { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus Explorer" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
      },
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope grep_string<cr>", desc = "Find Word Under Cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
    },
    opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        file_ignore_patterns = { "node_modules", ".git/", "target/" },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- Terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
    keys = {
      { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Terminal" },
      { "<leader>gg", "<cmd>lua _lazygit_toggle()<cr>", desc = "LazyGit" },
    },
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },

  -- Better notification system
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        fps = 60,
        icons = {
          DEBUG = "🔍",
          ERROR = "❌",
          INFO = "ℹ️",
          TRACE = "✎",
          WARN = "⚠️",
        },
        level = 2,
        minimum_width = 50,
        render = "wrapped-compact",
        stages = "fade_in_slide_out",
        time_formats = {
          notification = "%T",
          notification_history = "%FT%T",
        },
        timeout = 5000,
        top_down = true,
        max_width = 80,
        max_height = 20,
      })
      
      -- Override vim.notify
      vim.notify = require("notify")
      
      -- Keymap untuk notify history
      vim.keymap.set("n", "<leader>un", function()
        require("notify").history()
      end, { desc = "Notify History" })
    end,
  },

  -- Modern UI notifications
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        notify = {
          enabled = false, -- Disable noice notification, pakai notify langsung
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        routes = {
          {
            filter = {
              event = "msg_show",
              any = {
                { find = "%d+L, %d+B" },
                { find = "; after #%d+" },
                { find = "; before #%d+" },
              },
            },
            view = "mini",
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = true,
        },
      })

      -- Keymap untuk buka history
      vim.keymap.set("n", "<leader>nh", "<cmd>Noice history<cr>", { desc = "Notification History" })
      vim.keymap.set("n", "<leader>nd", "<cmd>Noice dismiss<cr>", { desc = "Dismiss Notifications" })
      vim.keymap.set("n", "<leader>nl", "<cmd>Noice last<cr>", { desc = "Last Message" })
      vim.keymap.set("n", "<leader>ne", "<cmd>Noice errors<cr>", { desc = "Error Messages" })
    end,
  },

  -- Telescope error search integration
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local builtin = require("telescope.builtin")
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local function search_errors()
        local messages = vim.fn.execute("messages")
        local lines = vim.split(messages, "\n")
        local errors = {}
        
        for _, line in ipairs(lines) do
          if line:match("Error") or line:match("error:") or line:match("E%d+") or line:match("rust%-analyzer") then
            table.insert(errors, line)
          end
        end
        
        if #errors == 0 then
          vim.notify("No errors found", vim.log.levels.INFO)
          return
        end
        
        pickers.new({}, {
          prompt_title = "Error History",
          finder = finders.new_table({
            results = errors,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            -- Copy ke clipboard dengan <C-y>
            map("i", "<C-y>", function()
              local selection = action_state.get_selected_entry()
              CopyToClipboard(selection[1])
              actions.close(prompt_bufnr)
            end)
            
            -- Copy dengan Enter juga
            map("i", "<CR>", function()
              local selection = action_state.get_selected_entry()
              CopyToClipboard(selection[1])
              actions.close(prompt_bufnr)
              
              -- Buka buffer baru untuk edit
              vim.cmd("new")
              vim.api.nvim_buf_set_lines(0, 0, -1, false, { selection[1] })
              vim.bo.modifiable = true
            end)
            
            return true
          end,
        }):find()
      end

      -- Tambahkan keymap
      vim.keymap.set("n", "<leader>se", search_errors, { desc = "Search Errors" })
    end,
  },
}