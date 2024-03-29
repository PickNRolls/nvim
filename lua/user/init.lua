vim.opt.guicursor = ""

vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = { "*.*" },
  desc = "save view (folds), when closing file",
  command = "mkview",
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "*.*" },
  desc = "load view (folds), when opening file",
  command = "silent! loadview"
})

local nav = function(count)
  local current_buf = vim.api.nvim_get_current_buf()

  for i, v in ipairs(vim.t.bufs) do
    if current_buf == v then
      local next = (i + count - 1) % #vim.t.bufs + 1

      vim.cmd.b(vim.t.bufs[next])
      break
    end
  end
end

return {
  lsp = {
    setup_handlers = {
      -- add custom handler
      rust_analyzer = function(_, opts) require("rust-tools").setup { server = opts } end
    },
    formatting = {
      format_on_save = true,
      filter = function(client)
        if vim.bo.filetype == "typescript" or
            vim.bo.filetype == "typescriptreact" then
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.codeActionProvider = true
          end
          return client.name == "eslint"
        end

        if client.name == "null-ls" then
          client.server_capabilities.codeActionProvider = false
          return false
        end

        return true
      end
    },
    config = {
      clangd = {
        capabilities = { offsetEncoding = "utf-16" },
      },
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
      ["<leader>c"] = { function() require("astronvim.utils.buffer").close(nil, true) end, desc = "Close buffer" },
      ["<leader>w"] = false,
      ["<C-s>"] = { ":w!<cr>", desc = "Save File" },
      ["<C-j>"] = {
        function()
          if vim.opt.modifiable:get() then
            vim.cmd("norm o")
          else
            vim.cmd('exe "norm \\<c-w>j"')
          end
        end,
        desc = "New line under cursor"
      },
      ["<C-k>"] = {
        function()
          if vim.opt.modifiable:get() then
            vim.cmd("norm O")
          else
            vim.cmd('exe "norm \\<c-w>k"')
          end
        end,
        desc = "New line over cursor"
      },
      ["<Tab>"] = {
        function()
          nav(vim.v.count > 0 and vim.v.count or 1)
        end,
        desc = "Next buffer",
      },
      ["<S-Tab>"] = {
        function()
          nav(-(vim.v.count > 0 and vim.v.count or 1))
        end,
        desc = "Prev buffer",
      },
      ["<leader>fp"] = {
        function()
          require 'telescope'.extensions.projects.projects {}
        end
      }
    },

    t = {
      ["hh"] = { "<C-\\><C-n>" },
    },
  },
  highlights = {
    -- set highlights for all themes
    -- use a function override to let us use lua to retrieve colors from highlight group
    -- there is no default table so we don't need to put a parameter for this function
    init = function()
      local get_hlgroup = require("astronvim.utils").get_hlgroup
      -- get highlights from highlight groups
      local normal = get_hlgroup "Normal"
      local fg, bg = normal.fg, normal.bg
      local bg_alt = get_hlgroup("Visual").bg
      local green = get_hlgroup("String").fg
      local red = get_hlgroup("Error").fg
      -- return a table of highlights for telescope based on colors gotten from highlight groups
      return {
        TelescopeBorder = { fg = bg_alt, bg = bg },
        TelescopeNormal = { bg = bg },
        TelescopePreviewBorder = { fg = bg, bg = bg },
        TelescopePreviewNormal = { bg = bg },
        TelescopePreviewTitle = { fg = bg, bg = green },
        TelescopePromptBorder = { fg = bg_alt, bg = bg_alt },
        TelescopePromptNormal = { fg = fg, bg = bg_alt },
        TelescopePromptPrefix = { fg = red, bg = bg_alt },
        TelescopePromptTitle = { fg = bg, bg = red },
        TelescopeResultsBorder = { fg = bg, bg = bg },
        TelescopeResultsNormal = { bg = bg },
        TelescopeResultsTitle = { fg = bg, bg = bg },
      }
    end,
  },
  plugins = {
    {
      "ahmedkhalf/project.nvim",
      config = function()
        require("project_nvim").setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below

          patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "a.yaml", ".arcignore" },
        }
      end
    },
    {
      "nvim-telescope/telescope.nvim",
      opts = function()
        local actions = require "telescope.actions"
        require('telescope').load_extension('projects')
        local get_icon = require("astronvim.utils").get_icon
        return {
          defaults = {
            prompt_prefix = string.format(" %s ", get_icon "Search"),
            selection_caret = string.format("%s ", get_icon "Selected"),
            path_display = { "truncate" },
            sorting_strategy = "ascending",
            layout_config = {
              horizontal = {
                prompt_position = "bottom",
                preview_width = 0.55,
              },
              vertical = {
                mirror = false,
              },
              width = 0.87,
              height = 0.80,
              preview_cutoff = 120,
            },

            mappings = {
              i = {
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
              },
              n = { ["q"] = actions.close },
            },
          },
        }
      end,
    },
    "simrat39/rust-tools.nvim",
    {
      "kevinhwang91/nvim-ufo",
      opts = {
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (' 󰁂 %d '):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- str width returned from truncate() may less than 2nd argument, need padding
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, 'MoreMsg' })
          return newVirtText
        end
      },
    },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        ensure_installed = {
          "clangd",
          "cssls",
          "dockerls",
          "eslint",
          "html",
          "jsonls",
          "lua_ls",
          "tsserver",
        }, -- automatically install lsp
      },
    },
    {
      "kylechui/nvim-surround",
      version = "*", -- Use for stability; omit to use `main` branch for the latest features
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({})
      end
    },
    {
      "ggandor/leap.nvim"
    }
  }
}
