# Neovim Configuration (WSL-Debian & Cross-Platform)

A modular, high-performance Neovim configuration built with Lua, optimized for modern software development, AI tooling, and Neovim `0.12+`.

---

## Architecture & Features

- **Plugin Management**: [`lazy.nvim`](https://github.com/folke/lazy.nvim) for fast, declarative plugin loading.
- **Tree-sitter**: Modern [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) (`main` branch) with native Neovim 0.12 highlighting, indentation, and injections.
- **Textobjects**: [`nvim-treesitter-textobjects`](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) with custom repeatable/hierarchical block selection (`ab` / `ib`).
- **Fuzzy Finding**: [`telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) with live grep, buffer management, `.nvimignore` integration, and LSP symbol search.
- **LSP & Tooling**: [`mason.nvim`](https://github.com/williamboman/mason.nvim), `mason-lspconfig`, and native `nvim-lspconfig`.
- **Completion & Snippets**: `nvim-cmp` with LuaSnip and buffer/LSP sources.
- **Markdown & Documentation**: [`render-markdown.nvim`](https://github.com/MeanderingProgrammer/render-markdown.nvim) with in-buffer concealed rendering and callout support.
- **AI Integration**: Support for Claude Code (`claudecode.nvim`), Gemini (`gemini.nvim`), and `codecompanion.nvim`.
- **Git & Diffing**: [`diffview.nvim`](https://github.com/sindrets/diffview.nvim) and [`codediff.nvim`](https://github.com/esensar/nvim-dev-container).
- **File Explorer**: [`neo-tree.nvim`](https://github.com/nvim-neo-tree/neo-tree.nvim).

---

## Requirements (WSL-Debian)

- **Neovim**: `v0.12.0+`
- **Compiler**: `gcc` or `clang` (`build-essential`)
- **CLI Tools**: `curl`, `tar`, `git`, `ripgrep`, `fd-find`
- **Tree-sitter CLI**: `tree-sitter` (v0.26+) in `$PATH` (installed to `~/.local/bin/tree-sitter`)
- **Node.js**: Required for various LSPs and tools

```bash
# Core tools on Debian/Ubuntu (WSL)
sudo apt update && sudo apt install -y build-essential curl git ripgrep fd-find

# Tree-sitter CLI (if not installed)
curl -sL https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.1/tree-sitter-linux-x64.gz | gzip -d > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter
```

---

## Directory Structure

```text
~/.config/nvim/
├── init.lua                      # Entry point (options, core, lazy bootstrap)
├── lazy-lock.json                # Plugin lockfile
├── lua/
│   ├── core.lua                  # General Neovim options & keymaps
│   └── plugins/
│       ├── treesitter.lua        # Treesitter (main), textobjects & block select
│       ├── telescope.lua         # Telescope fuzzy finder & pickers
│       ├── lsp.lua               # LSP, Mason, diagnostics
│       ├── codecompletion.lua    # nvim-cmp and LuaSnip
│       ├── conform.lua           # Formatting engine
│       ├── render-markdown.lua   # Markdown rendering
│       ├── neo-tree.lua          # File tree navigation
│       ├── lualine.lua           # Status line
│       ├── diffview.lua          # Git diff views
│       ├── codediff.lua          # Interactive code diffs
│       ├── claudecode.lua        # Claude Code integration
│       ├── gemini.lua            # Gemini AI integration
│       └── colorscheme.lua       # Theme (Catppuccin)
└── docs/
    └── TREESITTER_MIGRATION.md   # Neovim 0.12 Treesitter migration guide
```

---

## Keybindings Cheat Sheet

### Treesitter & Textobjects
| Keymap | Mode | Description |
|---|---|---|
| `af` / `if` | Visual, Operator | Around / Inside function |
| `ac` / `ic` | Visual, Operator | Around / Inside class |
| `al` / `il` | Visual, Operator | Around / Inside loop |
| `aa` / `ia` | Visual, Operator | Around / Inside argument/parameter |
| `ab` / `ib` | Visual, Operator | Smart hierarchical block selection (expand/shrink) |

### Telescope (Fuzzy Finder)
| Keymap | Mode | Description |
|---|---|---|
| `<leader>ff` | Normal | Find files (respects `.nvimignore`) |
| `<leader>fg` | Normal | Live grep across project |
| `<leader>fb` | Normal | Open buffers |
| `<leader>fh` | Normal | Help tags |
| `<leader>fo` | Normal | LSP document symbols (Classes, Interfaces, Structs) |
| `<leader>fu` | Normal | LSP document symbols (Functions, Methods) |
| `<leader>fr` | Normal | LSP references |
| `<leader>ws` | Normal | LSP workspace symbols |

### Markdown
| Keymap | Mode | Description |
|---|---|---|
| `<leader>mr` | Normal | Toggle rendered Markdown display |

---

## Branching Conventions

- `master`: Base tracking branch.
- `mac/zsh`: macOS specific configuration.
- `wsl/debian`: WSL2 Debian environment configuration.

See [`docs/TREESITTER_MIGRATION.md`](docs/TREESITTER_MIGRATION.md) for details on the Neovim 0.12 Tree-sitter overhaul.
