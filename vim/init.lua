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

local home = os.getenv("HOME")
local opts = {
  server = {
    cmd = { home .. "/.vim/shims/rustana" },
    settings = {
      ["rust-analyzer"] = {
        diagnostics = { disabled = { "unresolved-import" } },
        cargo = { loadOutDirsFromCheck = true },
        procMacro = { enable = true },
        checkOnSave = { command = "clippy" },
      },
    }
  }
}
require('rust-tools').setup(opts)

  -- Set up nvim-cmp.
do
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      {
        name = 'nvim_lsp',
        -- entry_filter = function(entry, _)
        --   return entry:get_kind() ~= cmp.lsp.CompletionItemKind.Text and entry:get_kind() ~= cmp.lsp.CompletionItemKind.Snippet
        -- end
      },
      { name = 'nvim_lsp_signature_help' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      -- { name = 'buffer' },
      { name = 'path' },
    })
  })

  -- Set configuration for specific filetype.
  -- cmp.setup.filetype('gitcommit', {
  --   sources = cmp.config.sources({
  --     { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  --   }, {
  --     { name = 'buffer' },
  --   })
  -- })

  cmp.setup.filetype('markdown', {
    enabled = function ()
      return false
    end
  })

  cmp.setup.filetype('text', {
    enabled = function ()
      return false
    end
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  -- might be slow
  --cmp.setup.cmdline({ '/', '?' }, {
  --  mapping = cmp.mapping.preset.cmdline(),
  --  sources = {
  --    { name = 'buffer' }
  --  }
  --})

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  -- annoying path completion for now
  -- cmp.setup.cmdline(':', {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = cmp.config.sources({
  --     { name = 'path' }
  --   }, {
  --     { name = 'cmdline' }
  --   })
  -- })

  -- Set up lspconfig.
  -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  -- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
  --   capabilities = capabilities
  -- }
end

local function nnoremap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, {buffer = 0, silent = true})
end

-- Repurpose cursor keys (accessible near homerow via "SpaceFN" layout) for one
-- of my most oft-use key sequences.
nnoremap('<S-Up>', vim.diagnostic.goto_prev)
nnoremap('<S-Down>', vim.diagnostic.goto_next)
