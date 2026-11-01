# Treesitter Migration & Neovim 0.12 Architecture

## Overview

This document describes the architectural changes and resolution for Tree-sitter in this Neovim configuration on **WSL-Debian** running **Neovim `v0.12`**.

---

## Background & Root Cause

In Neovim `0.12`, the internal Tree-sitter query engine underwent a breaking change: query capture matches (`match[capture_id]`) changed from returning a single node (`TSNode`) to returning an array of captured nodes (`TSNode[]`) in order to support quantified captures like `(node)+`.

When running legacy branches (`master`) of `nvim-treesitter`:
- Directives such as `#set-lang-from-info-string!` (used by Markdown code block injections) expected `match[capture_id]` to be a `TSNode`.
- Neovim passed a table (`{ [1] = <TSNode> }`), causing Lua to fail with:
  ```text
  Decoration provider "conceal_line" (ns=nvim.treesitter.highlighter):
  attempt to call method 'range' (a nil value)
  ```
- Additionally, legacy queries produced mismatch errors like `Query error at 74:3. Invalid field name "operator": operator: _ @operator)` against older compiled parsers.

Upstream `nvim-treesitter` froze the `master` branch and completed an incompatible rewrite on the **`main`** branch designed specifically for Neovim 0.12+.

---

## Migration Details

### 1. `tree-sitter-cli` Installation
The `main` branch of `nvim-treesitter` delegates compilation of parsers to the official `tree-sitter-cli` (`tree-sitter build` and `tree-sitter generate`) rather than maintaining its own compiler wrapper.

- **Binary**: `tree-sitter` (v0.27.1)
- **Path**: `~/.local/bin/tree-sitter`
- **Verification**: `tree-sitter --version`

### 2. Plugin Branch Updates
Both `nvim-treesitter` and `nvim-treesitter-textobjects` are updated to track `branch = "main"`:

```lua
{
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
  },
}
```

### 3. Native Neovim 0.12 Setup
The old `require("nvim-treesitter.configs").setup()` has been removed. Highlighting, folding, and indentation are managed through native Neovim APIs:

```lua
local ts = require("nvim-treesitter")

ts.setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Ensure parsers are installed asynchronously
local parsers = {
  "c", "lua", "vim", "vimdoc", "query",
  "javascript", "typescript", "html", "css",
  "markdown", "markdown_inline",
}
ts.install(parsers)

-- Enable native treesitter highlighting and indentation
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

### 4. Textobjects & Block Expansion
`nvim-treesitter-textobjects` now uses its standalone setup API:

- **Keymaps**: `af`/`if` (function), `ac`/`ic` (class), `al`/`il` (loop), `aa`/`ia` (parameter).
- **Hierarchical Block Selection (`ab` / `ib`)**: Re-implemented using `require("nvim-treesitter-textobjects.shared")` and Neovim's native visual selection range manipulation, eliminating dependencies on the removed `ts_utils.update_selection`.

---

## Maintenance & Commands

- **Update Parsers**: Run `:TSUpdate` in Neovim.
- **Install New Parser**: Run `:TSInstall <language>`.
- **Parser Location**: Parsers are compiled into `~/.local/share/nvim/site/parser/`.
