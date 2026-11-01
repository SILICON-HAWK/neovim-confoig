-- nvim/lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    -- Load default ignore patterns
    local patterns = { "node_modules", ".git/", "dist/", "build/", ".next/" }

    -- Try to read project-specific .nvimignore
    local ignore_file = vim.fn.getcwd() .. "/.nvimignore"
    if vim.fn.filereadable(ignore_file) == 1 then
      local custom = vim.fn.readfile(ignore_file)
      for _, line in ipairs(custom) do
        if line ~= "" then
          table.insert(patterns, line)
        end
      end
    end

    -- Telescope setup
    require("telescope").setup({
      defaults = {
        file_ignore_patterns = patterns,
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })

    -- Built-in pickers keymaps
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy Find: Files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Fuzzy Find: Live Grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Fuzzy Find: Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Fuzzy Find: Help Tags" })

    -- LSP finders
    vim.keymap.set("n", "<leader>fo", function()
      builtin.lsp_document_symbols({
        symbols = { "Class", "Struct", "Interface", "Enum", "Object", "TypeParameter", "Namespace", "Module" },
      })
    end, { desc = "LSP: Find Object" })

    vim.keymap.set("n", "<leader>fu", function()
      builtin.lsp_document_symbols({ symbols = { "Function", "Method", "Constructor", "Operator" } })
    end, { desc = "LSP: Find Function" })

    vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "LSP: Find References" })
    vim.keymap.set("n", "<leader>ws", builtin.lsp_workspace_symbols, { desc = "LSP: Workspace Symbols" })
  end,
}

