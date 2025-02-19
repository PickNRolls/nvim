return {
  -- the colorscheme should be available when starting Neovim
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup({
        mappings = {
          i = {
            h = {
              h = "<esc>",
            },
          },
          t = {
            h = {
              h = "<c-\\><c-n>",
            },
          },
        },
      })
    end,
  },

  -- {
  --   "nvimtools/none-ls.nvim",
  --   dependencies = {
  --     "nvimtools/none-ls-extras.nvim",
  --   },
  --   config = function()
  --     local null_ls = require("null-ls")
  --
  --     null_ls.setup({
  --       debug = true,
  --       sources = {
  --         require("none-ls.diagnostics.eslint_d"),
  --       },
  --     })
  --   end,
  -- },

  {
    "williamboman/mason.nvim",
    lazy = false,
  },

  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    tag = "0.1.8",
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<c-j>"] = actions.move_selection_next,
              ["<c-k>"] = actions.move_selection_previous,
            },
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = {
            "%lock.json",
          },
        },
      })
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<c-j>"] = cmp.mapping.select_next_item(),
          ["<c-k>"] = cmp.mapping.select_prev_item(),
          ["<c-e>"] = cmp.mapping.abort(),
          ["<cr>"] = cmp.mapping.confirm(),
          ["<tab>"] = cmp.mapping(function(fallback)
            if luasnip.expandable() then
              luasnip.expand()
            elseif cmp.visible() then
              if #cmp.get_entries() == 1 then
                if luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  cmp.confirm({ select = true })
                end
              else
                cmp.select_next_item()
              end
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<s-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          -- { name = "buffer" },
          { name = "luasnip" },
        }),
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          ["<c-j>"] = {
            c = function()
              require("cmp").select_next_item()
            end,
          },
          ["<c-k>"] = {
            c = function()
              require("cmp").select_prev_item()
            end,
          },
        }),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },

  { "akinsho/toggleterm.nvim", version = "*", config = true },

  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "arkav/lualine-lsp-progress" },
  },

  {
    "rcarriga/nvim-notify",
    lazy = false,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },

  { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },

  { "windwp/nvim-ts-autotag", lazy = false },

  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({})
    end,
  },

  {
    "echasnovski/mini.nvim",
    version = "*",
  },

  { "echasnovski/mini.nvim",  version = "*" },

  {
    "axkirillov/hbac.nvim",
    config = true,
  },

  {
    "ggandor/leap.nvim",
    lazy = false,
  },

  {
    "echasnovski/mini.indentscope",
    version = "*",
    config = function()
      -- vim.cmd("au FileType * if index(['lua', 'python'], &ft) < 0 | lua vim.b.miniindentscope_disable=true | endif")
      require("mini.indentscope").setup({})
    end,
  },

  {
    "stevearc/dressing.nvim",
    opts = {},
  },
}
