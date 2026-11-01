return {
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

  config = function()
    local ts = require("nvim-treesitter")

    ts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Ensure parsers are installed
    local parsers = {
      "c",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "javascript",
      "typescript",
      "html",
      "css",
      "markdown",
      "markdown_inline",
    }
    ts.install(parsers)

    -- Enable Treesitter highlighting and indent natively for all filetypes with installed parsers
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Setup nvim-treesitter-textobjects
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local textobject_keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
    }
    for key, query in pairs(textobject_keymaps) do
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(query, "textobjects")
      end)
    end

    -- Smart hierarchical block selection: 'ab' (around block) and 'ib' (inside block)
    local shared = require("nvim-treesitter-textobjects.shared")
    local ts_range = vim.treesitter._range or require("nvim-treesitter-textobjects._range")

    local function update_selection(range, selection_mode)
      local start_row, start_col, end_row, end_col = ts_range.unpack4(range)
      selection_mode = selection_mode or "v"

      local mode = vim.api.nvim_get_mode()
      if mode.mode ~= selection_mode then
        selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)
        vim.cmd.normal({ selection_mode, bang = true })
      end

      if end_col == 0 then
        end_row = end_row - 1
        end_col = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, true)[1] + 1
      end

      local end_col_offset = 1
      if selection_mode == "v" and vim.o.selection == "exclusive" then
        end_col_offset = 0
      end
      end_col = end_col - end_col_offset

      vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      vim.cmd("normal! o")
      vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
    end

    local chain = nil

    local function sorted_candidates(captures)
      local out = {}
      local seen = {}
      for _, cap in ipairs(captures) do
        local range = shared.textobject_at_point(cap, "textobjects", nil, nil, {})
        if range then
          local srow, scol, erow, ecol = ts_range.unpack4(range)
          local key = string.format("%d,%d,%d,%d", srow, scol, erow, ecol)
          if not seen[key] then
            seen[key] = true
            out[#out + 1] = {
              range = range,
              line_span = erow - srow,
              col_span = ecol - scol,
              cap = cap,
            }
          end
        end
      end
      table.sort(out, function(a, b)
        if a.line_span ~= b.line_span then
          return a.line_span < b.line_span
        end
        return a.col_span < b.col_span
      end)
      return out
    end

    local function selection_pos()
      return vim.fn.getpos("'<"), vim.fn.getpos("'>")
    end

    local function matches(a, b)
      return a and b and a[1][2] == b[1][2] and a[1][3] == b[1][3] and a[2][2] == b[2][2] and a[2][3] == b[2][3]
    end

    local function select_block(captures)
      local mode = vim.fn.mode(1)
      local keymap_mode = mode:find("o") and "o" or "x"
      local buf = vim.api.nvim_get_current_buf()

      local candidates = sorted_candidates(captures)
      if #candidates == 0 then
        return
      end

      if keymap_mode == "x" and chain and chain.buf == buf and matches(chain.last, { selection_pos() }) then
        if chain.idx < #chain.list then
          chain.idx = chain.idx + 1
        end
        update_selection(chain.list[chain.idx].range, "v")
        chain.last = { selection_pos() }
        return
      end

      chain = { buf = buf, list = candidates, idx = 1 }
      update_selection(chain.list[1].range, "v")
      chain.last = { selection_pos() }
    end

    vim.keymap.set({ "o", "x" }, "ab", function()
      select_block({
        "@class.outer",
        "@function.outer",
        "@conditional.outer",
        "@loop.outer",
        "@call.outer",
        "@block.outer",
        "@statement.outer",
      })
    end, { desc = "Select around block" })

    vim.keymap.set({ "o", "x" }, "ib", function()
      select_block({
        "@class.inner",
        "@function.inner",
        "@conditional.inner",
        "@loop.inner",
        "@block.inner",
      })
    end, { desc = "Select inside block" })
  end,
}
