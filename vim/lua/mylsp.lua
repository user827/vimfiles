local lspconfig = require('lspconfig')

local function nnoremap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, {buffer = 0, silent = true})
end

local gid = vim.api.nvim_create_augroup('lsp_global_aucmds', {clear = false})
vim.api.nvim_clear_autocmds({group = gid})
vim.api.nvim_create_autocmd({'User'}, {group = gid, pattern = 'LspProgressStatusUpdated', callback = vim.schedule_wrap(
function() vim.cmd('redrawstatus') end)})


local function on_attach(client)
  nnoremap('<Leader>gq',    vim.diagnostic.setqflist)
  nnoremap('<Leader>gl',    vim.diagnostic.setloclist)
  nnoremap('<Leader>ld', vim.diagnostic.open_float)
  vim.api.nvim_win_set_option(0, 'signcolumn', 'yes')

  nnoremap('<c-]>', vim.lsp.buf.definition)
  nnoremap('K',     vim.lsp.buf.hover)
  nnoremap('<Leader>gD',    vim.lsp.buf.implementation)
  nnoremap('1K',    vim.lsp.buf.signature_help)
  nnoremap('<Leader>1gD',   vim.lsp.buf.type_definition)
  nnoremap('<Leader>gr',    vim.lsp.buf.references)
  nnoremap('<Leader>g0',    vim.lsp.buf.document_symbol)
  nnoremap('<Leader>gW',    vim.lsp.buf.workspace_symbol)
  nnoremap('<Leader>gA',    vim.lsp.buf.code_action)
  nnoremap('<Leader>gd',    vim.lsp.buf.declaration)
end

-- setup lsps
do
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      update_in_insert = false,
    }
  )

  require('lsp-progress').setup()
  local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- print(vim.inspect(lspconfig.util.default_config))
  lspconfig.util.default_config = vim.tbl_deep_extend("force", lspconfig.util.default_config, {
    on_attach = on_attach,
    capabilities = vim.tbl_deep_extend("force", {}, cmp_capabilities)
  })
  -- print(vim.inspect(cmp_capabilities))
  -- print(vim.inspect(lspconfig.util.default_config))

  -- TODO still used with lsp-progress?
  -- TODO why does vim.cmd not work here?
  vim.api.nvim_command('sign define LspDiagnosticsSignError text=')
  vim.api.nvim_command('sign define LspDiagnosticsSignWarning text=')
  vim.api.nvim_command('sign define LspDiagnosticsSignInformation text=ℹ')
  vim.api.nvim_command('sign define LspDiagnosticsSignHint text=➤')
  vim.api.nvim_command('highlight! link LspDiagnosticsSignError ALEErrorSign')
  vim.api.nvim_command('highlight! link LspDiagnosticsSignWarning ALEWarningSign')
  vim.api.nvim_command('highlight! link LspDiagnosticsSignInformation ALEInfoSign')
  vim.api.nvim_command('highlight! link LspDiagnosticsSignHint ALEInfoSign')


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

  local cmd = home .. '/javascriptlib/node_modules/.bin/diagnostic-languageserver'
  if vim.fn.executable(cmd) == 1 then
    lspconfig.diagnosticls.setup {
      -- cmd = { home .. '/bin/lsplog', 'diagnosticls', home .. '/javascriptlib/node_modules/.bin/diagnostic-languageserver', '--stdio', '--log-level', '2' },
      cmd = { cmd, '--stdio', '--log-level', '2' },
      root_dir = lspconfig.util.path.dirname,
      filetypes = { 'sh' },
      -- on_attach = setup_status,
      -- todo why atuocmd error on textdocuemnt/documentsymbol?
      -- on_attach = function() end,
      init_options = {
        filetypes = {
          -- python = {'mypy', 'pylint'},
          -- python = {'mypy'},
          -- python = {'pylint'},
          sh = {'shellcheck'},
        },
        linters = {
          shellcheck = {
            command = "shellcheck",
            debounce = 100,
            args = {
              "--format",
              "json",
              "-"
            },
            sourceName = "shellcheck",
            parseJson = {
              line = "line",
              column = "column",
              endLine = "endLine",
              endColumn = "endColumn",
              message = "${message} [${code}]",
              security = "level"
            },
            securities = {
              error = "error",
              warning = "warning",
              info = "info",
              style = "hint"
            }
          },
          pylint = {
            sourceName = "pylint",
            command = "pylint",
            args = {
              "--output-format",
              "text",
              "--score",
              "no",
              "--msg-template",
              "'{line}:{column}:{category}:{msg} ({msg_id}:{symbol})'",
              "%file"
            },
            formatPattern = {
              "^(\\d+?):(\\d+?):([a-z]+?):(.*)$",
              {
                line = 1,
                column = 2,
                security = 3,
                message = 4
              }
            },
            rootPatterns = {".git", "pyproject.toml", "setup.py"},
            securities = {
              informational = "hint",
              refactor = "info",
              convention = "info",
              warning = "warning",
              error = "error",
              fatal = "error"
            },
            offsetColumn = 1,
            formatLines = 1,
          },
          mypy = {
            sourceName = "mypy",
            command = "mypy",
            args = {
              "--no-color-output",
              "--no-error-summary",
              "--show-column-numbers",
              "--follow-imports=silent",
              "%file"
            },
            formatPattern = {
              "^.*:(\\d+?):(\\d+?): ([a-z]+?): (.*)$",
              {
                line = 1,
                column = 2,
                security = 3,
                message = 4
              }
            },
            securities = {
              error = "error"
            }
          }
        }
      }
    }
  end

  lspconfig.omnisharp.setup {
    cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
  }

  lspconfig.pylsp.setup {}

  -- lspconfig.jedi_language_server.setup {
  --    root_dir = lspconfig.util.path.dirname,
  --    --callbacks = {
  --      --['textDocument/publishDiagnostics'] = multi_diagnostics_cb,
  --    --},
  --  }

  lspconfig.bashls.setup {
  }

  lspconfig.vimls.setup {}

  lspconfig.gopls.setup {
    cmd = { home .. "/.vim/shims/gopls" },
    settings = {
      gopls = {
        staticcheck = true,
      }
    }
  }

  lspconfig.clangd.setup {}

  lspconfig.solargraph.setup {}

  lspconfig.tsserver.setup {}


  local rcstart = 'file://' .. home .. '/.config/awesome/'
  local lualspcmd = "lua-language-server"
  if vim.fn.executable(lualspcmd) == 1 then
    lspconfig.lua_ls.setup{
      cmd = { lualspcmd },
      on_new_config = function(config)
        local uri = vim.uri_from_bufnr(0)
        if uri:sub(1, #rcstart) == rcstart then
          config.settings.Lua.diagnostics.globals = vim.tbl_extend(
            "force",
            config.settings.Lua.diagnostics.globals, {
              'awesome', 'mouse', 'screen', 'client', 'root'
            })
          -- print(vim.inspect(config))
          table.insert(config.settings.Lua.runtime.path,
            '/usr/share/awesome/lib/?.lua'
          )
          table.insert(config.settings.Lua.runtime.path,
            '/usr/share/awesome/lib/?/?.lua'
          )
          -- print('matches')
        end
      end,
      settings = {
        Lua = {
          diagnostics = {
            enable = true,
            globals = {'vim'},
          },
          filetypes = {'lua'},
          runtime = {
            path = vim.split(package.path, ';'),
            version = 'LuaJIT',
          },
        }
      },
    }
  end
end

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
      { name = 'buffer' },
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

require('glow').setup({
  -- your override config
})
