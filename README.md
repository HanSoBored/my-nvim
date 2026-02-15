# My Nvim Setup

Setup ini Menggunakan Stater Template [LazyVim](https://github.com/LazyVim/LazyVim).

Berikut daftar lengkap keymap dan command yang tersedia setelah setup:

## Keymaps Rust (Leader + r...)

| Keymap | Fungsi | Keterangan |
|--------|--------|------------|
| `<leader>rs` | **Start rust-analyzer** | Manual trigger dengan auto-detect project root |
| `<leader>rS` | **Stop rust-analyzer** | Matikan LSP |
| `<leader>r?` | **Status rust-analyzer** | Cek running atau tidak + project root |
| `<leader>rP` | **Detect Project Root** | Tampilkan dan copy project root ke clipboard |
| `<leader>rE` | **View Rust Errors** | Buka buffer dengan history error Rust |
| `<leader>rC` | **Copy All Rust Errors** | Copy semua error ke clipboard |
| `<leader>rl` | **View LSP Log** | Buka file log rust-analyzer |
| `<leader>re` | **Explain Error** | Jelaskan error (butuh LSP running) |
| `<leader>rd` | **Open Docs** | Buka dokumentasi rust (docs.rs) |
| `<leader>rp` | **Parent Module** | Loncat ke parent module |
| `<leader>rc` | **Open Cargo.toml** | Buka Cargo.toml project |
| `<leader>rf` | **Format** | Format file dengan rustfmt |
| `<leader>rn` | **Rename** | Rename symbol |
| `<leader>ca` | **Code Action** | Quick fix dari LSP |
| `<leader>dr` | **Debuggables** | Debug Rust program |

## Keymaps Cargo/Crates (Leader + c...)

| Keymap | Fungsi | Keterangan |
|--------|--------|------------|
| `<leader>ct` | **Toggle crates.nvim** | Show/hide crate versions |
| `<leader>cr` | **Reload crates** | Refresh crate info |
| `<leader>cv` | **Show Versions** | Popup versi crate |
| `<leader>cf` | **Show Features** | Popup feature flags |
| `<leader>cd` | **Show Dependencies** | Popup dependencies |
| `<leader>cu` | **Update Crate** | Update crate di Cargo.toml |
| `<leader>cU` | **Upgrade Crate** | Upgrade ke versi terbaru |
| `<leader>ca` | **Update All** | Update semua crates |
| `<leader>cA` | **Upgrade All** | Upgrade semua crates |
| `<leader>cx` | **Expand to Inline** | Expand crate ke inline table |
| `<leader>cX` | **Extract to Table** | Extract ke table terpisah |
| `<leader>cH` | **Open Homepage** | Buka homepage crate |
| `<leader>cR` | **Open Repository** | Buka GitHub repo |
| `<leader>cD` | **Open Docs** | Buka docs.rs crate |
| `<leader>cC` | **Open crates.io** | Buka crates.io |

## Keymaps LSP General

| Keymap | Fungsi |
|--------|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Show references |
| `<leader>dn` | Next diagnostic |
| `<leader>dp` | Previous diagnostic |
| `<leader>dl` | Diagnostic list |

## Keymaps Noice (Notification)

| Keymap | Fungsi |
|--------|--------|
| `<leader>nh` | Noice History (semua notifikasi) |
| `<leader>ne` | Noice Errors (hanya error) |
| `<leader>nd` | Dismiss notifications |
| `<leader>nl` | Last message |
| `<leader>un` | Notify history |

## Commands (Command Mode)

| Command | Fungsi |
|---------|--------|
| `:RustErrors` | View Rust error history |
| `:CopyAllRustErrors` | Copy semua error ke clipboard |
| `:ClearRustErrors` | Hapus error history |
| `:LspLog` | Buka LSP log file |
| `:DebugRustAutocmd` | Debug autocmd Rust (untuk troubleshooting) |
| `:Messages` | View full messages (bisa di-copy) |
| `:CopyLastError` | Copy error terakhir ke clipboard |

## Workflow Penggunaan

### 1. Buka Project Rust dari Mana Saja
```bash
cd ~
nvim
# Di nvim: <leader>e ke ~/MyWorkspace/project/src/main.rs
```

### 2. Start LSP
```
<leader>rs        # Start rust-analyzer (auto-detect project root)
```

### 3. Coding dengan Features
```
gd                # Go to definition
K                 # Hover docs
<leader>ca        # Code action (quick fix)
<leader>rf        # Format file
```

### 4. Cek Error
```
<leader>rE        # View error history
<leader>nh        # Noice notification history
```

### 5. Manage Dependencies (di Cargo.toml)
```
<leader>cv        # Lihat versi crate
<leader>cu        # Update crate
```

### 6. Stop LSP
```
<leader>rS        # Stop rust-analyzer
```

## Tips

- **Icon warning/error** hanya muncul setelah `<leader>rs` dan ada diagnostics
- **Project root** otomatis terdeteksi dari lokasi `Cargo.toml`
