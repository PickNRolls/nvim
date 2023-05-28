vim.opt.guicursor = ""

return {
  lsp = {
    formatting = {
      format_on_save = true,
    },
  },
  mappings = {
    i = {
      ["hh"] = { "<Esc>", desc = "Go to normal mode" },
      ["<C-k>"] = { "<Up>", desc = "Move cursor up" },
      ["<C-j>"] = { "<Down>", desc = "Move cursor down" },
      ["<C-h>"] = { "<Left>", desc = "Move cursor left" },
      ["<C-l>"] = { "<Right>", desc = "Move cursor right" },
    },

    n = {
      ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
      ["<C-j>"] = { "o<Esc>", desc = "New line under cursor" },
      ["<C-k>"] = { "O<Esc>", desc = "New line over cursor" },
      ["<Tab>"] = {
        function()
          require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1)
        end,
        desc = "Next buffer",
      },
      ["<S-Tab>"] = {
        function()
          require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1))
        end,
        desc = "Prev buffer",
      },
    },

    t = {
      ["hh"] = { "<C-\\><C-n>" },
    },
  },
}
