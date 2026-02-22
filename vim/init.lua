vim.g.snacks_animate = true

-- todo install conform

-- from lazy vim
-- icons used by other plugins
-- stylua: ignore
local icons = {
  misc = {
    dots = "󰇘",
  },
  ft = {
    octo = " ",
    gh = " ",
    ["markdown.gh"] = " ",
  },
  dap = {
    Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint          = " ",
    BreakpointCondition = " ",
    BreakpointRejected  = { " ", "DiagnosticError" },
    LogPoint            = ".>",
  },
  diagnostics = {
    Error = " ",
    Warn  = " ",
    Hint  = " ",
    Info  = " ",
  },
  git = {
    added    = " ",
    modified = " ",
    removed  = " ",
  },
  kinds = {
    Array         = " ",
    Boolean       = "󰨙 ",
    Class         = " ",
    Codeium       = "󰘦 ",
    Color         = " ",
    Control       = " ",
    Collapsed     = " ",
    Constant      = "󰏿 ",
    Constructor   = " ",
    Copilot       = " ",
    Enum          = " ",
    EnumMember    = " ",
    Event         = " ",
    Field         = " ",
    File          = " ",
    Folder        = " ",
    Function      = "󰊕 ",
    Interface     = " ",
    Key           = " ",
    Keyword       = " ",
    Method        = "󰊕 ",
    Module        = " ",
    Namespace     = "󰦮 ",
    Null          = " ",
    Number        = "󰎠 ",
    Object        = " ",
    Operator      = " ",
    Package       = " ",
    Property      = " ",
    Reference     = " ",
    Snippet       = "󱄽 ",
    String        = " ",
    Struct        = "󰆼 ",
    Supermaven    = " ",
    TabNine       = "󰏚 ",
    Text          = " ",
    TypeParameter = " ",
    Unit          = " ",
    Value         = " ",
    Variable      = "󰀫 ",
  },
}

local vimrc = vim.fn.stdpath("config") .. "/vimrc"
vim.cmd.source(vimrc)
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
-- vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
-- i want to work with multiple clipboards
vim.opt.pumblend = 10

require('mini.pairs').setup({
  modes = { insert = true, command = true, terminal = false },
  -- skip autopair when next character is one of these
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  -- skip autopair when the cursor is inside these treesitter nodes
  skip_ts = { "string" },
  -- skip autopair when next character is closing pair
  -- and there are more closing pairs than opening pairs
  skip_unbalanced = true,
  -- better deal with markdown code blocks
  markdown = true,
})

require('tokyonight').setup({
})

require('flash').setup({
})

require('dap-go').setup()
require('dap').set_log_level('DEBUG')

-- require('catppuccin').setup({
--   background = {
--     dark = 'macchiato'
--   }
-- })

require('nvim-treesitter').setup({})

require('which-key').setup({
  preset = 'helix',
  defaults = {},
  spec = {
    {
      mode = { "n", "x" },
      { "<leader><tab>", group = "tabs" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>dp", group = "profiler" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>q", group = "quit/session" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui" },
      { "<leader>x", group = "diagnostics/quickfix" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "gs", group = "surround" },
      { "z", group = "fold" },
      {
        "<leader>b",
        group = "buffer",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      },
      {
        "<leader>w",
        group = "windows",
        proxy = "<c-w>",
        expand = function()
          return require("which-key.extras").expand.win()
        end,
      },
      -- better descriptions
      { "gx", desc = "Open with system app" },
    },
  }
})

require('snacks').setup({
  animate = {},
  scroll = {},
  explorer = {},
  -- does not flicker unlike nvim-notify
  notifier = {},
  picker = {
    exclude = {
      "Downloads",
      "Pictures",
      "Videos",
    },
  },
  image = {},
  -- otherwise the previous plugins kill the performance. even profiler does not
  -- show why
  bigfile = {},
  profiler = {},
  toggle = {},
  util = {},
  rename = {},
  bufdelete = {},
  -- for [i ]i
  scope = {},
  words = {},
  -- so slow
  --indent = {
  --  scope = {
  --    enabled = false
  --  }
  --},
})

require('noice').setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      view = "mini",
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
  },
})


require('bufferline').setup({
  options = {
    -- stylua: ignore
    close_command = function(n) Snacks.bufdelete(n) end,
    -- stylua: ignore
    right_mouse_command = function(n) Snacks.bufdelete(n) end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    diagnostics_indicator = function(_, _, diag)
      local icons = icons.diagnostics
      local ret = (diag.error and icons.Error .. diag.error .. " " or "")
      .. (diag.warning and icons.Warn .. diag.warning or "")
      return vim.trim(ret)
    end,
    highlights = require("catppuccin.special.bufferline").get_theme(),
    offsets = {
      {
        filetype = "neo-tree",
        text = "Neo-tree",
        highlight = "Directory",
        text_align = "left",
      },
      {
        filetype = "snacks_layout_box",
      },
    },
    ---@param opts bufferline.IconFetcherOpts
    get_element_icon = function(opts)
      return icons.ft[opts.filetype]
    end
  }
})
-- todo bufferline autocmds

require'trouble'.setup({
  modes = {
    lsp = {
      win = { position = "right" },
    }
  }
})

require'colorizer'.setup()

require'mini.icons'.setup()
require'nvim-web-devicons'.setup()

require'hardtime'.setup()

require'gitsigns'.setup({
  signs = {
    delete = { text = "" },
    topdelete = { text = "" },
  },
  signs_staged = {
    delete = { text = "" },
    topdelete = { text = "" },
  },
  on_attach = function(buffer)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, desc)
      vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
    end

    -- stylua: ignore start
    map("n", "]h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next Hunk")
    map("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Prev Hunk")
    map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
    map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
    map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
    map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
    map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
    map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
    map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
    map("n", "<leader>ghd", gs.diffthis, "Diff This")
    map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  end,
})

require("luasnip.loaders.from_vscode").lazy_load()

local neogit = require('neogit')

-- custom_solarized.normal.a.fg = '#112233'
require('lsp-progress').setup({
})
local lualine_opts = {
  options = {
    theme = "auto",
    globalstatus = vim.o.laststatus == 3,
    disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
  },
  sections = {
    -- Other Status Line components
    lualine_a = { "mode" },
    lualine_b = { "FugitiveHead" },
    lualine_c = {
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      {
        'filename',
        path = 1,
      },
      function()
        -- invoke `progress` here.
        return require('lsp-progress').progress()
      end,
    },
    lualine_x = {
      {
        'encoding',
        cond = function() if vim.api.nvim_get_option_value("fileencoding", {buf = 0}) == 'utf-8' then return false else return true end end
      },
      {
        'fileformat',
        cond = function() if vim.api.nvim_get_option_value("fileformat", {buf = 0}) == 'unix' then return false else return true end end
      },
      Snacks.profiler.status(),
      {
        'diff',
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          removed = icons.git.removed,
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      }
    },
    ...
  }
}

local trouble = require("trouble")
local symbols = trouble.statusline({
  mode = "lsp_document_symbols",
  groups = {},
  title = false,
  filter = { range = true },
  format = "{kind_icon}{symbol.name:Normal}",
  -- The following line is needed to fix the background color
  -- Set it to the lualine section you want to use
  hl_group = "lualine_c_normal",
})
table.insert(lualine_opts.sections.lualine_c, {
  symbols.get,
  cond = symbols.has,
})

require("lualine").setup(lualine_opts)

-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})

require("grug-far").setup({
  headerMaxWidth = 80
})

-- Plugin configuration
require('blink.cmp').setup({
  snippets = {
    preset = "luasnip"
  },

  keymap = {
    preset = 'enter',
    ["<C-y>"] = { "select_and_accept" }
  },

  appearance = {
    nerd_font_variant = 'mono'
  },

  completion = {
    menu = {
      draw = {
        treesitter = { "lsp" },
      }
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    -- ghost_text = {
    --   enabled = true
    -- },
    --list = { selection = { preselect = true, auto_insert = true } },
  },

  cmdline = {
    enabled = true,
    keymap = {
      preset = "cmdline",
      ["<Right>"] = false,
      ["<Left>"] = false,
    },
    completion = {
      list = { selection = { preselect = false } },
      menu = {
        auto_show = function(ctx)
          return vim.fn.getcmdtype() == ":"
        end,
      },
      ghost_text = { enabled = true },
    }
  },

  fuzzy = {
    implementation = "prefer_rust_with_warning"
  },

  sources = {
    -- default = { "lsp", "path", "snippets", "buffer", "copilot" },
    -- providers = {
    --   copilot = {
    --     name = "copilot",
    --     module = "blink-cmp-copilot",
    --     score_offset = 100,
    --     async = true,
    --   },
    -- },
    per_filetype = {
      ['copilot-chat'] = { },
      markdown = { },
    }
  }
})

local keys = {
  -- Top Pickers & Explorer
  { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
  { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
  { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
  { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
  { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
  -- find
  { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
  { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
  { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
  { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
  { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
  { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
  -- git
  { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
  { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
  { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
  { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
  { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
  { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
  { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
  { "<leader>gG", function() Snacks.picker.git_grep() end, desc = "Git Grep" },
  -- gh
  { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
  { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
  { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
  { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
  -- Grep
  { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
  { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
  { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
  { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
  -- search
  { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
  { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
  { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
  { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
  { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
  { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
  { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
  { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
  { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
  { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
  { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
  { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
  { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
  { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
  { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
  { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
  { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
  { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
  { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
  { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
  { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
  -- LSP
  { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
  { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
  { "grr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
  { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
  { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
  { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
  { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
  { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  -- Other
  { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
  { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
  { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
  { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
  { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
  { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
  { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
  { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
  --{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
  { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
  { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
  { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },

  { "<leader>ps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Bufer" },

  {
    "<leader>xx",
    "<cmd>Trouble diagnostics toggle<cr>",
    desc = "Diagnostics (Trouble)",
  },
  {
    "<leader>xX",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Buffer Diagnostics (Trouble)",
  },
  {
    "<leader>cs",
    "<cmd>Trouble symbols toggle focus=false<cr>",
    desc = "Symbols (Trouble)",
  },
  {
    "<leader>cl",
    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    desc = "LSP Definitions / references / ... (Trouble)",
  },
  {
    "<leader>xL",
    "<cmd>Trouble loclist toggle<cr>",
    desc = "Location List (Trouble)",
  },
  {
    "<leader>xQ",
    "<cmd>Trouble qflist toggle<cr>",
    desc = "Quickfix List (Trouble)",
  },

  { "<leader>gg", neogit.open, desc = "Open Neogit UI" },

  { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
  { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
  { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
  { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
  { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
  { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
  { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
  { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },

  { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
  { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
  { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
  { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  -- Simulate nvim-treesitter incremental selection
  { "<c-space>", mode = { "n", "o", "x" },
  function()
    require("flash").treesitter({
      actions = {
        ["<c-space>"] = "next",
        ["<BS>"] = "prev"
      }
    })
  end, desc = "Treesitter Incremental Selection" },

  { "<leader>sn", "", desc = "+noice"},
  { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
  { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
  { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
  { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
  { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
  { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
  { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
  { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
}

for _, value in ipairs(keys) do
  local mode = value.mode or 'n'
  value.silent = true
  local key = value[1]
  local cmd = value[2]
  value[1] = nil
  value[2] = nil
  value.mode = nil
  vim.keymap.set(mode, key, cmd, value)
end

Snacks.toggle.profiler():map("<leader>pp")
Snacks.toggle.profiler_highlights():map("<leader>ph")

require 'mylsp'
require 'keymaps'
require 'autocmds'
