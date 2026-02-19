-- requires net
--local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--if not vim.loop.fs_stat(lazypath) then
--  print("hello")
--  vim.fn.system({
--    "git",
--    "clone",
--    "--filter=blob:none",
--    "https://github.com/folke/lazy.nvim.git",
--    "--branch=stable", -- latest stable release
--    lazypath,
--  })
--end
--vim.opt.rtp:prepend(lazypath)
--
--local plugins = {
--  {"ellisonleao/glow.nvim", config = true, cmd = "Glow"}
--}
--
--local opts = {}
--
--require("lazy").setup(plugins, opts)

local vimrc = vim.fn.stdpath("config") .. "/vimrc"
vim.cmd.source(vimrc)

require 'mylsp'

require('dap-go').setup()
require('dap').set_log_level('DEBUG')

require('glow').setup({
  -- your override config
})

-- Plugin configuration
require('blink.cmp').setup({
  keymap = { preset = 'default' },

  appearance = {
    nerd_font_variant = 'mono'
  },

  completion = {
    documentation = { auto_show = true },
    list = { selection = { preselect = true, auto_insert = true } },
  },

  cmdline = {
    completion = {
      menu = {
        auto_show = true
      }
    }
  },

  fuzzy = {
    implementation = "prefer_rust_with_warning"
  }
})

local home = os.getenv("HOME")
local opts = {
  server = {
    cmd = { home .. "/.vim/shims/rustana" },
    settings = {
      ["rust-analyzer"] = {
        diagnostics = { disabled = { "unresolved-import" } },
        cargo = { loadOutDirsFromCheck = true },
        procMacro = { enable = true },
        checkOnSave = true,
        check = {
          command = "clippy"
        }
      },
    }
  }
}

local function nnoremap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, {silent = true})
end

-- Repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one
-- of my most oft-use key sequences.
nnoremap('<S-Up>', vim.diagnostic.goto_prev)
nnoremap('<S-Down>', vim.diagnostic.goto_next)
nnoremap('<Leader>gq',    vim.diagnostic.setqflist)
nnoremap('<Leader>gl',    vim.diagnostic.setloclist)
nnoremap('<Leader>ld', vim.diagnostic.open_float)
