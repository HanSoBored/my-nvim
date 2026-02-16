return {
  -- Rust tools dengan rust-analyzer - MANUAL TRIGGER ONLY
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- State untuk tracking
      local rust_lsp_started = false

      -- Debug: Cek siapa yang trigger cargo
      vim.api.nvim_create_autocmd("LspAttach", {
        pattern = "*.rs",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "rust-analyzer" then
            vim.notify("🦀 rust-analyzer attached to: " .. vim.api.nvim_buf_get_name(args.buf), vim.log.levels.INFO)
          end
        end,
      })

      -- Helper untuk notify yang kompatibel dengan noice
      local function rust_notify(msg, level)
        level = level or "info"
        local ok, notify = pcall(require, "notify")
        if ok then
          notify(msg, level, { title = "Rust" })
        else
          vim.notify(msg, vim.log.levels[level:upper()] or vim.log.levels.INFO)
        end
      end

      vim.g.rustaceanvim = {
        tools = {
          executor = require("rustaceanvim.executors").termopen,
          reload_workspace_from_cargo_toml = true,
          inlay_hints = {
            auto = false,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
            highlight = "Comment",
          },
          hover_actions = {
            auto_focus = false,
          },
        },
        server = {
          -- PENTING: auto_attach = false mencegah auto-start
          auto_attach = false,

          on_attach = function(client, bufnr)
            rust_lsp_started = true

            -- Enable inlay hints manual - compatible with different Neovim versions
            if vim.lsp.inlay_hint then
              local ok, _ = pcall(function()
                -- Try new API first (Neovim 0.11+)
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end)

              if not ok then
                -- Fallback to old API (Neovim 0.10.x)
                pcall(function()
                  vim.lsp.inlay_hint.enable(bufnr, true)
                end)
              end
            end

            -- Keymaps khusus Rust (hanya aktif setelah LSP dijalankan)
            local bufopts = { buffer = bufnr, silent = true }

            -- Hover dengan rust-specific
            vim.keymap.set("n", "K", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr, desc = "Rust Hover Actions" })

            -- Format
            vim.keymap.set("n", "<leader>rf", function()
              vim.lsp.buf.format({ async = true })
            end, { buffer = bufnr, desc = "Rust Format" })

            -- Rename
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })

            -- Go to definition/implementation
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to Definition" })
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to Declaration" })
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to Implementation" })
            vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "References" })

            -- Diagnostics
            vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next Diagnostic" })
            vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Prev Diagnostic" })
            vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { buffer = bufnr, desc = "Diagnostic List" })

            -- Show notification menggunakan notify yang sudah di-setup noice
            local notify = require("notify")
            notify("🦀 rust-analyzer started!", "info", { title = "Rust" })
          end,

          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },
              -- DISABLE checkOnSave to prevent error 101 during file opening
              -- Will be enabled only after manual start
              checkOnSave = false,
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
              diagnostics = {
                enable = true,
                experimental = {
                  enable = true,
                },
              },
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
                closureReturnTypeHints = { enable = "never" },
                lifetimeElisionHints = { enable = "never", useParameterNames = false },
                maxLength = 25,
                parameterHints = { enable = true },
                reborrowHints = { enable = "never" },
                renderColons = true,
                typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
              },
              lens = {
                enable = true,
                debug = true,
                implementations = true,
                run = true,
                methodReferences = true,
                references = true,
              },
              rustfmt = {
                extraArgs = { "+nightly" },
              },
              completion = {
                postfix = { enable = true },
                autoimport = { enable = true },
              },
            },
          },
        },
        dap = {
          adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
          },
        },
      }

      -- ============================================================================
      -- GLOBAL KEYBINDINGS (Manual Trigger) - DI LUAR on_attach
      -- ============================================================================

      -- Fungsi helper untuk cek apakah rustaceanvim sudah ready
      local function is_rustaceanvim_ready()
        local ok, _ = pcall(require, "rustaceanvim")
        return ok
      end

      -- Helper untuk notify yang kompatibel dengan noice
      local function rust_notify(msg, level)
        level = level or "info"
        local ok, notify = pcall(require, "notify")
        if ok then
          notify(msg, level, { title = "Rust" })
        else
          vim.notify(msg, vim.log.levels[level:upper()] or vim.log.levels.INFO)
        end
      end

      -- Helper untuk mencari root direktori proyek Rust
      local function find_rust_project_root(path)
        -- Cari Cargo.toml ke atas
        local root = vim.fs.find("Cargo.toml", {
          upward = true,
          path = path,
          stop = vim.loop.os_homedir(),
        })[1]

        if root then
          return vim.fs.dirname(root)
        end

        -- Fallback: cari .git
        local git_root = vim.fs.find(".git", {
          upward = true,
          path = path,
          stop = vim.loop.os_homedir(),
        })[1]

        if git_root then
          return vim.fs.dirname(git_root)
        end

        return path
      end

      -- Start rust-analyzer manual dengan auto-detect project root dan chdir
      vim.keymap.set("n", "<leader>rs", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype

        if ft ~= "rust" then
          rust_notify("❌ Not a Rust file!", "warn")
          return
        end

        -- Check if already started
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "rust-analyzer" })
        if #clients > 0 then
          rust_notify("ℹ️ rust-analyzer already running", "info")
          return
        end

        -- AUTO-DETECT PROJECT ROOT
        local current_file = vim.api.nvim_buf_get_name(bufnr)
        local current_dir = vim.fn.fnamemodify(current_file, ":p:h")

        -- Cari Cargo.toml secara rekursif ke atas
        local root_dir = nil
        local dir = current_dir

        while dir ~= "/" and dir ~= "" and dir ~= vim.loop.os_homedir() do
          local cargo_toml = dir .. "/Cargo.toml"
          if vim.fn.filereadable(cargo_toml) == 1 then
            root_dir = dir
            break
          end
          local parent = vim.fn.fnamemodify(dir, ":h")
          if parent == dir then
            break
          end
          dir = parent
        end

        if not root_dir then
          rust_notify("❌ No Cargo.toml found! Not in a Rust project?", "error")
          return
        end

        -- PENTING: Change working directory ke project root
        -- Ini yang membuat cargo check berjalan di directory yang benar
        local original_cwd = vim.fn.getcwd()
        vim.cmd("lcd " .. vim.fn.fnameescape(root_dir))

        rust_notify("Starting rust-analyzer in: " .. root_dir, "info")

        -- Cek apakah rustaceanvim sudah loaded
        if not is_rustaceanvim_ready() then
          rust_notify("❌ rustaceanvim not loaded yet", "error")
          return
        end

        -- Start rust-analyzer
        local ok, err = pcall(function()
          local config = vim.g.rustaceanvim
          local client_config = vim.tbl_deep_extend("force", {}, config.server or {})
          client_config.name = "rust-analyzer"
          client_config.cmd = { "rust-analyzer" }
          client_config.root_dir = root_dir

          -- ENABLE checkOnSave only for manual start
          client_config.settings = vim.deepcopy(client_config.settings or {})
          client_config.settings["rust-analyzer"] = client_config.settings["rust-analyzer"] or {}
          client_config.settings["rust-analyzer"].checkOnSave = {
            allFeatures = true,
            command = "clippy",
            extraArgs = { "--no-deps" },
          }

          vim.lsp.start(client_config, {
            bufnr = bufnr,
            reuse_client = function(client, conf)
              return client.name == conf.name
            end,
          })
        end)

        if not ok then
          -- Restore cwd kalau gagal
          vim.cmd("lcd " .. vim.fn.fnameescape(original_cwd))
          rust_notify("Failed to start: " .. tostring(err), "error")
          return
        end

        -- Set buffer-local working directory supaya tetap di project root
        -- meskipun user navigate ke file lain
        vim.api.nvim_buf_set_var(bufnr, "rust_project_root", root_dir)

        -- Autocmd untuk restore cwd saat buffer ini di-switch
        vim.api.nvim_create_autocmd("BufEnter", {
          buffer = bufnr,
          callback = function()
            local buf_root = vim.b[bufnr].rust_project_root
            if buf_root and vim.fn.getcwd() ~= buf_root then
              vim.cmd("lcd " .. vim.fn.fnameescape(buf_root))
            end
          end,
        })

        -- Enable nvim-lint for this buffer after LSP starts
        local ok_lint, lint = pcall(require, "lint")
        if ok_lint then
          -- Enable clippy linter for this specific buffer
          vim.b[bufnr].lint = { "clippy" }
          -- Trigger linting once to initialize
          lint.try_lint()
          rust_notify("🦀 rust-analyzer started in " .. root_dir .. " (clippy enabled)", "info")
        else
          rust_notify("🦀 rust-analyzer started in " .. root_dir, "info")
        end
      end, { desc = "🦀 Start rust-analyzer (Auto root)", silent = true })

      -- Stop rust-analyzer
      vim.keymap.set("n", "<leader>rS", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "rust-analyzer" })

        if #clients == 0 then
          rust_notify("❌ rust-analyzer not running", "warn")
          return
        end

        for _, client in ipairs(clients) do
          vim.lsp.stop_client(client.id)
        end
        rust_lsp_started = false

        -- Disable buffer-specific linter
        vim.b[bufnr].lint = {}

        rust_notify("🛑 rust-analyzer stopped", "info")
      end, { desc = "🛑 Stop rust-analyzer", silent = true })

      -- Check status
      vim.keymap.set("n", "<leader>r?", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr, name = "rust-analyzer" })

        if #clients > 0 then
          rust_notify("✅ rust-analyzer is RUNNING (client id: " .. clients[1].id .. ")", "info")
        else
          rust_notify("❌ rust-analyzer is NOT running (use <leader>rs to start)", "warn")
        end
      end, { desc = "Check rust-analyzer status", silent = true })

      -- ============================================================================
      -- RUST-SPECIFIC COMMANDS (Hanya jika LSP sudah running)
      -- ============================================================================

      -- Code Action (LSP standard)
      vim.keymap.set("n", "<leader>ca", function()
        local clients = vim.lsp.get_active_clients({ bufnr = 0, name = "rust-analyzer" })
        if #clients == 0 then
          rust_notify("❌ rust-analyzer not running. Press <leader>rs first!", "warn")
          return
        end
        vim.lsp.buf.code_action()
      end, { desc = "Code Action" })

      -- Explain Error (rust-specific, butuh rustaceanvim)
      vim.keymap.set("n", "<leader>re", function()
        local clients = vim.lsp.get_active_clients({ bufnr = 0, name = "rust-analyzer" })
        if #clients == 0 then
          rust_notify("❌ rust-analyzer not running. Press <leader>rs first!", "warn")
          return
        end

        -- Coba panggil RustLsp jika sudah tersedia
        local ok, _ = pcall(vim.cmd.RustLsp, "explainError")
        if not ok then
          -- Fallback: explain error manual
          rust_notify("RustLsp command not available yet. Try again in a few seconds...", "warn")
        end
      end, { desc = "Explain Error" })

      -- Open Docs
      vim.keymap.set("n", "<leader>rd", function()
        local clients = vim.lsp.get_active_clients({ bufnr = 0, name = "rust-analyzer" })
        if #clients == 0 then
          vim.notify("❌ rust-analyzer not running", vim.log.levels.WARN)
          return
        end

        local ok, _ = pcall(vim.cmd.RustLsp, "openDocs")
        if not ok then
          vim.ui.open("https://docs.rs/")
        end
      end, { desc = "Open Docs" })

      -- Parent Module
      vim.keymap.set("n", "<leader>rp", function()
        local clients = vim.lsp.get_active_clients({ bufnr = 0, name = "rust-analyzer" })
        if #clients == 0 then
          vim.notify("❌ rust-analyzer not running", vim.log.levels.WARN)
          return
        end

        local ok, _ = pcall(vim.cmd.RustLsp, "parentModule")
        if not ok then
          -- Fallback: go to parent file manual
          local current = vim.fn.expand("%:p")
          local parent = vim.fn.fnamemodify(current, ":h")
          if parent ~= current then
            vim.cmd("edit " .. parent)
          end
        end
      end, { desc = "Parent Module" })

      -- Open Cargo.toml
      vim.keymap.set("n", "<leader>rc", function()
        local cargo = vim.fs.find("Cargo.toml", { upward = true, path = vim.fn.expand("%:p:h") })[1]
        if cargo then
          vim.cmd("edit " .. cargo)
        else
          rust_notify("❌ Cargo.toml not found", "error")
        end
      end, { desc = "Open Cargo.toml" })

      -- Cek root dir yang terdeteksi
      vim.keymap.set("n", "<leader>rP", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local current_file = vim.api.nvim_buf_get_name(bufnr)
        local current_dir = vim.fn.fnamemodify(current_file, ":p:h")

        local root_dir = find_rust_project_root(current_dir)
        if root_dir then
          rust_notify("Project root: " .. root_dir, "info")
          -- Copy ke clipboard
          vim.fn.setreg("+", root_dir)
        else
          rust_notify("No Cargo.toml found from: " .. current_dir, "warn")
        end
      end, { desc = "Detect Project Root" })

      -- Debuggables
      vim.keymap.set("n", "<leader>dr", function()
        local clients = vim.lsp.get_active_clients({ bufnr = 0, name = "rust-analyzer" })
        if #clients == 0 then
          rust_notify("❌ rust-analyzer not running", "warn")
          return
        end

        local ok, _ = pcall(vim.cmd.RustLsp, "debuggables")
        if not ok then
          rust_notify("Debuggables not available yet", "warn")
        end
      end, { desc = "Rust Debuggables" })

      -- ============================================================================
      -- RUST ERROR LOGGING SYSTEM (TANPA OVERRIDE vim.notify)
      -- ============================================================================

      local rust_errors = {}

      -- Gunakan autocmd untuk capture error, BUKAN override vim.notify
      vim.api.nvim_create_autocmd("User", {
        pattern = "Notify",
        callback = function(args)
          local data = args.data
          if data and type(data.message) == "string" then
            local msg = data.message
            if msg:match("rust") or msg:match("Rust") or data.level == "error" then
              table.insert(rust_errors, {
                time = os.date("%H:%M:%S"),
                message = msg,
                level = data.level or "info",
              })

              if #rust_errors > 50 then
                table.remove(rust_errors, 1)
              end
            end
          end
        end,
      })

      -- Alternative: capture dari LSP diagnostics
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        pattern = "*.rs",
        callback = function(args)
          local diagnostics = args.data.diagnostics
          for _, diag in ipairs(diagnostics) do
            if diag.severity == vim.diagnostic.severity.ERROR then
              table.insert(rust_errors, {
                time = os.date("%H:%M:%S"),
                message = diag.message,
                level = "error",
                source = diag.source,
              })
            end
          end
        end,
      })

      vim.api.nvim_create_user_command("RustErrors", function()
        if #rust_errors == 0 then
          rust_notify("No Rust errors captured yet", "info")
          return
        end

        local lines = { "# Rust Error History", "" }
        for _, err in ipairs(rust_errors) do
          local icon = err.level == "error" and "❌" or "⚠️"
          table.insert(lines, string.format("%s [%s] %s", icon, err.time, err.message))
          if err.source then
            table.insert(lines, "   Source: " .. err.source)
          end
          table.insert(lines, "")
        end

        vim.cmd("vsplit")
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        vim.bo[buf].modifiable = false
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].filetype = "markdown"
        vim.cmd("setlocal wrap")
        vim.cmd("setlocal cursorline")

        vim.keymap.set("n", "y", function()
          local line = vim.api.nvim_get_current_line()
          vim.fn.setreg("+", line)
          rust_notify("📋 Copied: " .. line:sub(1, 50), "info")
        end, { buffer = buf })

        vim.keymap.set("n", "q", "<cmd>q<cr>", { buffer = buf })
      end, {})

      vim.keymap.set("n", "<leader>rE", "<cmd>RustErrors<cr>", { desc = "View Rust Errors" })

      vim.api.nvim_create_user_command("CopyAllRustErrors", function()
        if #rust_errors == 0 then
          rust_notify("No errors to copy", "warn")
          return
        end

        local text = ""
        for _, err in ipairs(rust_errors) do
          text = text .. string.format("[%s] %s\n", err.time, err.message)
        end

        vim.fn.setreg("+", text)
        rust_notify(string.format("📋 Copied %d errors to clipboard", #rust_errors), "info")
      end, {})

      vim.keymap.set("n", "<leader>rC", "<cmd>CopyAllRustErrors<cr>", { desc = "Copy All Rust Errors" })

      vim.api.nvim_create_user_command("ClearRustErrors", function()
        rust_errors = {}
        rust_notify("🗑️ Rust error history cleared", "info")
      end, {})

      -- LSP Log
      vim.api.nvim_create_user_command("LspLog", function()
        local log_path = vim.lsp.get_log_path()
        vim.cmd("tabedit " .. log_path)
        vim.cmd("setlocal wrap")
        vim.cmd("normal! G")
      end, {})

      vim.keymap.set("n", "<leader>rl", "<cmd>LspLog<cr>", { desc = "View LSP Log" })
    end,
  },

  -- Cargo.toml tools
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        smart_insert = true,
        insert_closing_quote = true,
        avoid_prerelease = true,
        autoload = true,
        autoupdate = true,
        loading_indicator = true,
        date_format = "%Y-%m-%d",
        thousands_separator = ".",
        notification_title = "Crates",
        curl_args = { "-sL", "--retry", "1" },
        max_parallel_requests = 80,
        open_programs = { "xdg-open", "open" },
        expand_crate_moves_cursor = true,
        enable_update_available_warning = true,
        on_attach = function(bufnr)
          local crates = require("crates")
          local opts = { buffer = bufnr, silent = true }

          vim.keymap.set("n", "<leader>ct", crates.toggle, opts)
          vim.keymap.set("n", "<leader>cr", crates.reload, opts)
          vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, opts)
          vim.keymap.set("n", "<leader>cf", crates.show_features_popup, opts)
          vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, opts)
          vim.keymap.set("n", "<leader>cu", crates.update_crate, opts)
          vim.keymap.set("v", "<leader>cu", crates.update_crates, opts)
          vim.keymap.set("n", "<leader>ca", crates.update_all_crates, opts)
          vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, opts)
          vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, opts)
          vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, opts)
          vim.keymap.set("n", "<leader>cx", crates.expand_plain_crate_to_inline_table, opts)
          vim.keymap.set("n", "<leader>cX", crates.extract_crate_into_table, opts)
          vim.keymap.set("n", "<leader>cH", crates.open_homepage, opts)
          vim.keymap.set("n", "<leader>cR", crates.open_repository, opts)
          vim.keymap.set("n", "<leader>cD", crates.open_documentation, opts)
          vim.keymap.set("n", "<leader>cC", crates.open_crates_io, opts)
        end,
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "rust", "toml" })
    end,
  },

  -- Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "codelldb", "taplo" })
    end,
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          showDisassembly = "never",
        },
      }
    end,
  },

  -- Test runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust")({
            args = { "--no-capture" },
            dap_adapter = "codelldb",
          }),
        },
      })
    end,
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Test",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Test Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open()
        end,
        desc = "Test Output",
      },
    },
  },
}

