local lspconfig = require('lspconfig')

local function nnoremap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, {buffer = 0, silent = true})
end

local gid = vim.api.nvim_create_augroup('lsp_global_aucmds', {clear = false})
vim.api.nvim_clear_autocmds({group = gid})
vim.api.nvim_create_autocmd({'User'}, {group = gid, pattern = 'LspProgressStatusUpdated', callback = vim.schedule_wrap(
function() vim.cmd('redrawstatus') end)})


local function on_attach(client)
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

  lspconfig.ts_ls.setup {}


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
