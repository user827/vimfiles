local function noremap(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = 0, silent = true, desc = desc })
end


-- setup lsps
do
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


      local keys = {
        { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
        -- in snacks picker
        --{ "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
        --{ "gr", vim.lsp.buf.references, desc = "References", nowait = true },
        --{ "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
        --{ "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
        --{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
        --{ "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
        { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
        { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
        { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
        { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
        { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
        --{ "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
        { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
          desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
        { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
          desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
        { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
          desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
        { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
          desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
      }

      for _, value in ipairs(keys) do
        local mode = value.mode or 'n'
        if not value.has or (value.has and client:supports_method(value.has) or client:supports_method('textDocument/' .. value.has)) then
          noremap(mode, value[1], value[2], value.desc)
        end
      end
    end,
  })

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
      -- because lazyvim has
      stylua = { enabled = false },
      -- from nvim-lspconf
      lua_ls = {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath('config')
              and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              -- Tell the language server which version of Lua you're using (most
              -- likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
              -- Tell the language server how to find Lua modules same way as Neovim
              -- (see `:h lua-module-load`)
              path = {
                'lua/?.lua',
                'lua/?/init.lua',
              },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                -- Depending on the usage, you might want to add additional paths
                -- here.
                -- '${3rd}/luv/library',
                -- '${3rd}/busted/library',
              },
              -- Or pull in all of 'runtimepath'.
              -- NOTE: this is a lot slower and will cause issues when working on
              -- your own configuration.
              -- See https://github.com/neovim/nvim-lspconfig/issues/3189
              -- library = vim.api.nvim_get_runtime_file('', true),
            },
          })
        end,
        settings = {
          Lua = {
            codeLens = {
              enable = true,
            },
            completion = {
              callSnippet = "Replace",
            },
            doc = {
              privateName = { "^_" },
            },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      }
    }
  }

  for server, config in pairs(opts.servers) do
    -- passing config.capabilities to blink.cmp merges with the capabilities in your
    -- `opts[server].capabilities, if you've defined it
    config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities, true)
    config.capabilities = vim.tbl_deep_extend('force', config.capabilities, {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        }
      }
    })
    vim.lsp.enable(server)
    vim.lsp.config(server, config)
  end


  -- lspconfig.jedi_language_server.setup {
  --    root_dir = lspconfig.util.path.dirname,
  --    --callbacks = {
  --      --['textDocument/publishDiagnostics'] = multi_diagnostics_cb,
  --    --},
  --  }

    -- setup autoformat
    --LazyVim.format.register(LazyVim.lsp.formatter())

    -- setup keymaps
    --for server, server_opts in pairs(opts.servers) do
    --  if type(server_opts) == "table" and server_opts.keys then
    --    require("lazyvim.plugins.lsp.keymaps").set({ name = server ~= "*" and server or nil }, server_opts.keys)
    --  end
    --end

    -- inlay hints
      Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
        if
          vim.api.nvim_buf_is_valid(buffer)
          and vim.bo[buffer].buftype == ""
        then
          vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
        end
      end)

    -- folds
      Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function()
        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
      end)

      -- makes the lsp crunch all the time
    ---- code lens
    --  Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
    --    vim.lsp.codelens.refresh()
    --    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    --      buffer = buffer,
    --      callback = vim.lsp.codelens.refresh,
    --    })
    --  end)
end
