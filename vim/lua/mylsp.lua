local function nnoremap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, {buffer = 0, silent = true})
end

local gid = vim.api.nvim_create_augroup('lsp_global_aucmds', {clear = false})
vim.api.nvim_clear_autocmds({group = gid})
vim.api.nvim_create_autocmd({'User'}, {group = gid, pattern = 'LspProgressStatusUpdated', callback = vim.schedule_wrap(
function() vim.cmd('redrawstatus') end)})


-- setup lsps
do
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      update_in_insert = false,
    }
  )

  require('lsp-progress').setup()

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
      local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      if client:supports_method('textDocument/implementation') then
        -- Create a keymap for vim.lsp.buf.implementation ...
      end

      -- use blink.cmp instead
      ---- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
      --if client:supports_method('textDocument/completion') then
      --  -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      --  local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      --  client.server_capabilities.completionProvider.triggerCharacters = chars

      --  vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
      --end

      -- Auto-format ("lint") on save.
      -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
      -- if not client:supports_method('textDocument/willSaveWaitUntil')
      --     and client:supports_method('textDocument/formatting') then
      --   vim.api.nvim_create_autocmd('BufWritePre', {
      --     group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
      --     buffer = args.buf,
      --     callback = function()
      --       vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
      --     end,
      --   })
      -- end

      vim.api.nvim_win_set_option(0, 'signcolumn', 'yes')

      -- nnoremap('<c-]>', vim.lsp.buf.definition)
      ---- nnoremap('K',     vim.lsp.buf.hover)
      -- nnoremap('<Leader>gD',    vim.lsp.buf.implementation)
      -- nnoremap('1K',    vim.lsp.buf.signature_help)
      -- nnoremap('<Leader>1gD',   vim.lsp.buf.type_definition)
      -- nnoremap('<Leader>gr',    vim.lsp.buf.references)
      -- nnoremap('<Leader>g0',    vim.lsp.buf.document_symbol)
      -- nnoremap('<Leader>gW',    vim.lsp.buf.workspace_symbol)
      -- nnoremap('<Leader>gA',    vim.lsp.buf.code_action)
      -- nnoremap('<Leader>gd',    vim.lsp.buf.declaration)
    end,
  })

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
    servers = {
      rust_analyzer = {
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
      },
      diagnosticls = {
        -- cmd = { home .. '/bin/lsplog', 'diagnosticls', home .. '/javascriptlib/node_modules/.bin/diagnostic-languageserver', '--stdio', '--log-level', '2' },
        cmd = { home .. '/javascriptlib/node_modules/.bin/diagnostic-languageserver', '--stdio', '--log-level', '2' },
        -- root_dir = lspconfig.util.path.dirname,
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
      },
      omnisharp = {
        cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
      },
      pylsp = { },
      bashls = {},
      vimls = {},
      gopls = {
        cmd = { home .. "/.vim/shims/gopls" },
        settings = {
          gopls = {
            staticcheck = true,
          }
        }
      },

      solargraph = {},
      ts_ls = {},
      jsonnet_ls = {},

      bicep = {
        cmd = { "bicep-langserver" }
      },
      lua_ls = {
      }
    }
  }

  for server, config in pairs(opts.servers) do
    -- passing config.capabilities to blink.cmp merges with the capabilities in your
    -- `opts[server].capabilities, if you've defined it
    config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
    vim.lsp.enable(server)
    vim.lsp.config(server, config)
  end


  -- lspconfig.jedi_language_server.setup {
  --    root_dir = lspconfig.util.path.dirname,
  --    --callbacks = {
  --      --['textDocument/publishDiagnostics'] = multi_diagnostics_cb,
  --    --},
  --  }




end
