vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.o

o.expandtab = true
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2
o.number = true
o.numberwidth = 2
o.signcolumn = "yes:1"

vim.opt.termguicolors = true
vim.o.cmdheight = 0

require("config.lazy")

vim.notify = require("notify")

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "gopls",
    "ts_ls",
  },
})

require("mason-lspconfig").setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({})
  end,

  ["lua_ls"] = function()
    require("lspconfig").lua_ls.setup({
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      settings = {
        Lua = {
          diagnostics = {
            globals = {
              "vim",
              "require",
            },
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    })
  end,

  ["gopls"] = function()
    require("lspconfig").gopls.setup({
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      settings = {
        gopls = {
          usePlaceholders = true,
        },
      },
    })
  end,
})

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "go",
    "typescript",
    "json",
    "tsx",
    "javascript",
    "sql",
    "css",
    "html",
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

require("neo-tree").setup({
  window = {
    width = 30,
    auto_expand_width = true,
  },
  filesystem = {
    follow_current_file = {
      enabled = true,
    }
  },
  event_handlers = {
    {
      event = "file_open_requested",
      handler = function()
        require("neo-tree.command").execute({ action = "close" })
      end,
    },
  },
})

require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/LuaSnip/" })

local function show_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "Recording @" .. recording_register
  end
end
require("lualine").setup({
  options = {
    globalstatus = true,
  },
  sections = {
    lualine_b = {
      {
        "macro-recording",
        fmt = show_macro_recording,
      }
    },
    lualine_x = {
      "lsp_progress",
      "diagnostics",
    },
  },
})

require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
  },
})

require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,           -- Auto close tags
    enable_rename = true,          -- Auto rename pairs of tags
    enable_close_on_slash = false, -- Auto close on trailing </
  },
})

local spec_treesitter = require("mini.ai").gen_spec.treesitter
require("mini.ai").setup({
  custom_textobjects = {
    f = spec_treesitter({ a = "@call.outer", i = "@call.inner" }),
    F = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
    a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
    c = spec_treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
  },
})

require("mini.comment").setup({
  mappings = {
    comment_line = "<leader>/",
    comment_visual = "<leader>/"
  }
})

require("hbac").setup({
  autoclose = true, -- set autoclose to false if you want to close manually
  threshold = 6,    -- hbac will start closing unedited buffers once that number is reached
  close_command = function(bufnr)
    vim.api.nvim_buf_delete(bufnr, {})
  end,
  close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
  telescope = {
    -- See #telescope-configuration below
  },
})


local leap = require('leap')
leap.opts.equivalence_classes = { ' \t\r\n', '([{', ')]}', '\'"`' }

require("keymaps")
require("autocmd")
