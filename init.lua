-- =========================================================================
-- init.lua: single-file Neovim configuration (Neovim 0.12+, lazy.nvim)
--
--   0. Startup tuning and PATH setup
--   1. Plugin manager bootstrap
--   2. Plugin specifications
--   3. LSP servers
--   4. Core editor settings, autocmds, and file/layout guards
--   5. Commands and keymaps (navigation, selection, clipboard, terminals)
-- =========================================================================

-- Startup: stop the Lua garbage collector while modules load, so no GC sweeps run during startup
if collectgarbage then
  collectgarbage("stop")
end

-- Startup: cache compiled Lua bytecode to speed up subsequent launches
if vim.loader then
  vim.loader.enable()
end

-- Resume the garbage collector once lazy plugins have finished loading
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    if collectgarbage then
      collectgarbage("restart")
    end
  end,
})

-- Disable built-in plugins that are unused here (archive handlers, netrw, matchit, matchparen)
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1

-- Prepend common user tool directories (local bin, Go, Cargo, npm, scoop) to PATH when they exist
local is_win = vim.fn.has("win32") == 1
local path_sep = is_win and ";" or ":"
local extra_paths = {
  vim.fn.expand("~/.local/bin"),
  vim.fn.expand("~/go/bin"),
  vim.fn.expand("~/.cargo/bin"),
  vim.fn.expand("~/AppData/Roaming/npm"),
  vim.fn.expand("~/scoop/shims"),
}
for _, p in ipairs(extra_paths) do
  if vim.fn.isdirectory(p) == 1 and not string.find(vim.env.PATH, p, 1, true) then
    vim.env.PATH = p .. path_sep .. vim.env.PATH
  end
end

-- =========================================================================
-- 1. PLUGIN MANAGER BOOTSTRAP (lazy.nvim)
-- =========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Leader key: Space (must be set before plugins register keymaps)

-- =========================================================================
-- 2. PLUGINS CONFIGURATION
-- =========================================================================
require("lazy").setup({

  -- Colorscheme: TokyoNight, pure-black OLED palette with a transparent background
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = { bold = true },
          variables = {},
          sidebars = "transparent",
          floats = "transparent",
        },
        on_colors = function(colors)
          colors.bg = "#000000"
          colors.bg_dark = "#000000"
          colors.bg_float = "#000000"
          colors.bg_sidebar = "#000000"
          colors.bg_statusline = "#000000"
          colors.bg_popup = "#000000"
          colors.bg_search = "#3d59a1"
          colors.bg_visual = "#283457"
          colors.black = "#000000"
        end,
        on_highlights = function(hl, c)
          hl["@function"] = { fg = c.blue, bold = true }
          hl["@function.call"] = { fg = c.blue, bold = true }
          hl["@lsp.type.function"] = { fg = c.blue, bold = true }

          hl["@method"] = { fg = c.cyan, italic = true }
          hl["@method.call"] = { fg = c.cyan, italic = true }
          hl["@function.method"] = { fg = c.cyan, italic = true }
          hl["@lsp.type.method"] = { fg = c.cyan, italic = true }

          hl["@variable"] = { fg = c.fg }
          hl["@lsp.type.variable"] = { fg = c.fg }
          hl["@property"] = { fg = c.teal }
          hl["@lsp.type.property"] = { fg = c.teal }

          hl["@module"] = { fg = c.orange }
          hl["@namespace"] = { fg = c.orange }
          hl["@lsp.type.namespace"] = { fg = c.orange }
          hl["@type"] = { fg = c.magenta }
          hl["@lsp.type.type"] = { fg = c.magenta }
          hl["@type.builtin"] = { fg = c.magenta, italic = true }

          hl["@variable.parameter"] = { fg = c.yellow }
          hl["@lsp.type.parameter"] = { fg = c.yellow }

          hl["@constant"] = { fg = c.orange, bold = true }
          hl["@constant.builtin"] = { fg = c.orange, italic = true }
          hl["@boolean"] = { fg = c.orange }

          hl["@constructor"] = { fg = c.magenta, bold = true }
          hl["@function.method.call"] = { fg = c.cyan, italic = true }

          hl["@operator"] = { fg = c.blue5 }
          hl["@string.escape"] = { fg = c.magenta }
          hl["@variable.member"] = { fg = c.teal }

          -- Transparent backgrounds (to match the Ghostty window opacity) on a pure-black palette
          hl.Normal = { bg = "NONE", ctermbg = "NONE" }
          hl.NormalNC = { bg = "NONE", ctermbg = "NONE" }
          hl.NormalFloat = { bg = "NONE", ctermbg = "NONE" }
          hl.FloatBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }
          hl.FloatTitle = { fg = c.blue, bg = "NONE", bold = true }
          hl.FloatFooter = { fg = c.dark5 or c.comment, bg = "NONE" }

          hl.SignColumn = { bg = "NONE" }
          hl.SignColumnSB = { bg = "NONE" }
          hl.LineNr = { fg = c.dark5 or "#444b6a", bg = "NONE" }
          hl.CursorLineNr = { fg = c.yellow, bg = "NONE", bold = true }
          hl.FoldColumn = { bg = "NONE" }
          hl.Folded = { bg = "NONE", fg = c.comment }
          hl.EndOfBuffer = { fg = "#000000", bg = "NONE" }
          hl.MsgArea = { bg = "NONE" }

          hl.WinSeparator = { fg = "#292e42", bg = "NONE" }
          hl.VertSplit = { fg = "#292e42", bg = "NONE" }
          hl.WinBar = { bg = "NONE" }
          hl.WinBarNC = { bg = "NONE" }

          hl.StatusLine = { bg = "NONE" }
          hl.StatusLineNC = { bg = "NONE" }
          hl.TabLine = { bg = "NONE" }
          hl.TabLineFill = { bg = "NONE" }
          hl.TabLineSel = { bg = "NONE" }

          hl.NvimTreeNormal = { bg = "NONE" }
          hl.NvimTreeNormalNC = { bg = "NONE" }
          hl.NvimTreeWinSeparator = { fg = "#292e42", bg = "NONE" }
          hl.NvimTreeEndOfBuffer = { fg = "NONE", bg = "NONE" }

          hl.AerialNormal = { bg = "NONE" }
          hl.AerialNormalNC = { bg = "NONE" }
          hl.AerialLine = { bg = "#1f2335" }

          hl.FzfLuaNormal = { bg = "NONE" }
          hl.FzfLuaBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }
          hl.FzfLuaTitle = { fg = c.blue, bg = "NONE", bold = true }
          hl.FzfLuaBackdrop = { bg = "NONE" }
          hl.FzfLuaPreviewNormal = { bg = "NONE" }
          hl.FzfLuaPreviewBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }
          hl.FzfLuaPreviewTitle = { fg = c.magenta, bg = "NONE", bold = true }
          hl.FzfLuaCursor = { fg = c.bg, bg = c.fg }
          hl.FzfLuaCursorLine = { bg = "#283457" }
          hl.FzfLuaSearch = { fg = c.blue, bg = "NONE", bold = true }

          hl.BlinkCmpMenu = { bg = "NONE" }
          hl.BlinkCmpMenuBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }
          hl.BlinkCmpDoc = { bg = "NONE" }
          hl.BlinkCmpDocBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }
          hl.BlinkCmpSignatureHelp = { bg = "NONE" }
          hl.BlinkCmpSignatureHelpBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }

          hl.WhichKey = { bg = "NONE" }
          hl.WhichKeyNormal = { bg = "NONE" }
          hl.WhichKeyBorder = { fg = c.border_highlight or c.blue, bg = "NONE" }

          hl.NoiceCmdlinePopup = { bg = "NONE" }
          hl.NoiceCmdlinePopupBorder = { fg = c.blue, bg = "NONE" }
          hl.NoiceCmdline = { bg = "NONE" }
          hl.NoicePopup = { bg = "NONE" }
          hl.NoicePopupBorder = { fg = c.blue, bg = "NONE" }

          hl.Pmenu = { bg = "NONE" }
          hl.PmenuSel = { bg = "#283457" }
          hl.PmenuSbar = { bg = "NONE" }
          hl.PmenuThumb = { bg = "#444b6a" }

          hl.TroubleNormal = { bg = "NONE" }
          hl.TroubleNormalNC = { bg = "NONE" }
        end,
      })
      vim.cmd[[colorscheme tokyonight]]
    end,
  },

  -- Dashboard (alpha) with project/session shortcuts
  {
    "goolord/alpha-nvim",
    lazy = false,
    priority = 900,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      local logo = {
          [[    _  __                  _                ]],
          [[   / |/ /__  ___ _  __ __  (_) __ _         ]],
          [[  /    / -_)/ _ \ |/ // / / / /  ' \        ]],
          [[ /_/|_/\__/ \___/___/ \_,_//_/ /_/_/_/      ]],
          [[                                            ]],
          [[            Welcome, AniruddhRaam.          ]],
      }

      dashboard.section.header.val = {}
      for _ = 1, #logo do table.insert(dashboard.section.header.val, "") end

      local info_section = {
          type = "text",
          val = { "" },
          opts = { position = "center", hl = "Keyword" }
      }

      -- Point the global cwd back at the active project's root. auto-session derives the session name
      -- from the cwd, so this has to run BEFORE a save (a pre_save hook is too late: the name is fixed by then).
      _G.Pin_Project_Root = function()
        local root = _G._project_root
        if not root or vim.fn.isdirectory(root) ~= 1 then return false end
        vim.cmd("cd " .. vim.fn.fnameescape(root))
        return true
      end

      -- Save the active project's session under its own root, then tear the project down
      _G.Close_Project = function()
        pcall(function() require("aerial").close() end)
        pcall(function() require("nvim-tree.api").tree.close() end)
        vim.cmd("silent! wall") -- Save all modified buffers first
        -- Name the session explicitly after the project root so it can't depend on a drifted/stale cwd
        local root = _G.Pin_Project_Root() and _G._project_root or nil
        require("auto-session").save_session(root)
        for _, client in ipairs(vim.lsp.get_clients()) do client:stop() end -- Stop LSP servers on leaving a project (comment out to keep servers running)
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
            vim.cmd("bdelete! " .. bufnr)
          end
        end
        vim.v.this_session = "" -- Clear session to prevent overwriting on next project
        _G._project_root = nil
      end

      -- Universal project open helper: cleanly opens project in NvimTree and focuses code window
      _G.Open_Project_Directory = function(dir)
        if not dir or dir == "" then return end
        dir = vim.fn.expand(dir)
        if vim.fn.isdirectory(dir) ~= 1 then
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        if vim.fn.isdirectory(dir) ~= 1 then return end

        -- Switching away from an open project: save + close it first, so its buffers and session state
        -- can't leak into the new project's session.
        if _G._project_root and vim.fs.normalize(dir) ~= _G._project_root then
          _G.Close_Project()
        end

        vim.v.this_session = ""
        vim.cmd("cd " .. vim.fn.fnameescape(dir))
        -- Read the root back from the cwd: same canonical form auto-session names sessions from
        -- (no trailing slash, e.g. fd returns "dir/"), so the name and the saved `cd` always agree.
        _G._project_root = vim.fn.getcwd(-1, -1)

        -- 1. Open and update NvimTree root without focusing it
        local ok, tree_api = pcall(require, "nvim-tree.api")
        if ok then
          tree_api.tree.open({ path = dir, focus = false })
          pcall(tree_api.tree.change_root, dir)
          pcall(tree_api.tree.reload)
        else
          vim.cmd("NvimTreeOpen " .. vim.fn.fnameescape(dir))
        end

        -- 2. Focus the main code window and initialize a fresh buffer (replacing alpha dashboard if open)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" and ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "toggleterm" and ft ~= "trouble" then
              vim.api.nvim_set_current_win(win)
              if ft == "alpha" then
                local scratch = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_win_set_buf(win, scratch)
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
              break
            end
          end
        end
      end

      -- Custom function to search saved projects / sessions and jump straight into NvimTree
      _G.Open_Project_In_Tree = function()
        local status_ok, fzf = pcall(require, "fzf-lua")
        if not status_ok then return end
        local projects_set = {}
        local projects = {}

        local function add_project(dir)
          if dir and dir ~= "" and not projects_set[dir] and vim.fn.isdirectory(dir) == 1 then
            projects_set[dir] = true
            table.insert(projects, dir)
          end
        end

        -- 1. Legacy project.nvim history (only used if that data still exists on disk)
        local p_ok, p_history = pcall(require, "project_nvim.utils.history")
        if p_ok and p_history.get_recent_projects then
          for _, p in ipairs(p_history.get_recent_projects()) do add_project(p) end
        else
          local h_file = vim.fn.stdpath("data") .. "/project_nvim/project_history"
          if vim.fn.filereadable(h_file) == 1 then
            local f = io.open(h_file, "r")
            if f then
              for line in f:lines() do add_project(vim.trim(line)) end
              f:close()
            end
          end
        end

        -- 2. Projects recovered from auto-session's saved session files
        local as_ok, auto_session = pcall(require, "auto-session")
        if as_ok then
          local root_dir = auto_session.get_root_dir()
          local session_files = vim.fn.glob(root_dir .. "*.vim", false, true)
          for _, s_file in ipairs(session_files) do
            local fname = vim.fn.fnamemodify(s_file, ":t:r")
            local decoded = fname:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
            add_project(decoded)
          end
        end

        if #projects == 0 then
          vim.notify("No recent projects found", vim.log.levels.INFO, { title = "Projects" })
          return
        end

        fzf.fzf_exec(projects, {
          prompt = "Projects> ",
          actions = {
            ["default"] = function(selected)
              if selected and selected[1] then _G.Open_Project_Directory(selected[1]) end
            end,
            ["ctrl-e"] = function(selected)
              if selected and selected[1] then _G.Open_Project_Directory(selected[1]) end
            end,
          }
        })
      end

      -- Restore saved active session with full tab/buffer layout
      _G.Search_Sessions = function()
        local status_ok, as = pcall(require, "auto-session")
        if not status_ok then return end
        local s_ok, as_picker = pcall(require, "auto-session.pickers.fzf")
        if s_ok and as_picker.open_session_picker and as_picker.is_available() then
          as_picker.open_session_picker()
        else
          vim.cmd("AutoSession search")
        end
      end

      -- Directory browser using fzf-lua (searches from user home / root directory across all OSes)
      _G.Fzf_Browse_Dirs = function()
        local status_ok, fzf = pcall(require, "fzf-lua")
        if not status_ok then return end
        local root_dir = vim.fn.expand("~")
        local fd_cmd = string.format(
          'fd --color=never --type d --max-depth 5 --hidden --exclude .git --exclude node_modules --exclude .venv --exclude target --exclude .cache --exclude .local --exclude .cargo --exclude .rustup --exclude AppData . "%s"',
          root_dir
        )

        local function on_dir_selected(selected)
          if selected and selected[1] then
            _G.Open_Project_Directory(selected[1])
          end
        end

        fzf.fzf_exec(fd_cmd, {
          prompt = "Browse Directories (Root)> ",
          cwd = root_dir,
          actions = {
            ["default"] = on_dir_selected,
            ["ctrl-o"] = on_dir_selected,
            ["ctrl-e"] = on_dir_selected,
          },
        })
      end

      -- Dashboard buttons
      dashboard.section.buttons.val = {
          dashboard.button("f", "  Find file", "<cmd>FzfLua files<CR>"),
          dashboard.button("d", "󰉖  Browse Dirs", "<cmd>lua _G.Fzf_Browse_Dirs()<CR>"),
          dashboard.button("e", "󰙅  Open Project in Tree", "<cmd>lua _G.Open_Project_In_Tree()<CR>"),
          dashboard.button("r", "  Recent files", "<cmd>FzfLua oldfiles<CR>"),
          dashboard.button("p", "󰏋  Active Projects (Restore Tabs)", "<cmd>lua _G.Search_Sessions()<CR>"),
          dashboard.button("q", "󰅙  Quit NVIM", ":qa<CR>"),
      }

      dashboard.config.layout = {
          { type = "padding", val = function() return math.floor(vim.o.lines * 0.25) end },
          dashboard.section.header,
          { type = "padding", val = 2 },
          info_section,
          { type = "padding", val = function() return math.floor(vim.o.lines * 0.25) end },
          dashboard.section.buttons,
          { type = "padding", val = 1 },
      }

      alpha.setup(dashboard.opts)

      -- Error handling for dashboard: silence accidental keystrokes that would cause "E21: Cannot make changes, 'modifiable' is off"
      local function setup_alpha_key_handler(bufnr)
        bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
        local preserve_keys = {
          ["j"] = true, ["k"] = true, ["h"] = true, ["l"] = true,
          ["<Up>"] = true, ["<Down>"] = true, ["<Left>"] = true, ["<Right>"] = true,
          ["<CR>"] = true, ["<Tab>"] = true, ["<S-Tab>"] = true,
          ["<Esc>"] = true, [":"] = true, [" "] = true,
        }

        -- Preserve button shortcuts configured in dashboard
        for _, button in ipairs(dashboard.section.buttons.val or {}) do
          if button.opts and button.opts.shortcut then
            local sc = button.opts.shortcut:match("%s*(%S+)%s*")
            if sc then preserve_keys[sc] = true end
          end
        end

        if vim.g.mapleader then
          preserve_keys[vim.g.mapleader] = true
        end

        local keys_to_nop = {
          "i", "I", "a", "A", "o", "O", "s", "S", "c", "C", "r", "R", "u", "U",
          "x", "X", "d", "D", "p", "P", "y", "Y", "~", "J", "g", "G", "v", "V",
          "<C-v>", "<C-a>", "<C-x>", "<C-r>", "<BS>", "<Del>", "<Insert>",
          "<", ">", "=", ".",
        }
        for b = 32, 126 do
          table.insert(keys_to_nop, string.char(b))
        end

        for _, k in ipairs(keys_to_nop) do
          if not preserve_keys[k] then
            pcall(vim.keymap.set, { "n", "v" }, k, "<Nop>", { buffer = bufnr, silent = true, nowait = true })
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function(args)
          setup_alpha_key_handler(args.buf)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
              setup_alpha_key_handler(vim.api.nvim_get_current_buf())
              vim.b.miniindentscope_disable = true
              for i = 1, #logo do dashboard.section.header.val[i] = "" end
              local row, col, pause_ticks = 1, 1, 0
              local info_typed, info_col = false, 1

              local function get_datetime() return os.date("%A, %d-%m-%Y  |  %H:%M:%S") end

              local function draw_frame()
                  if vim.bo.filetype ~= "alpha" then return end
                  local needs_redraw = false

                  if pause_ticks > 0 then
                      pause_ticks = pause_ticks - 1
                      if pause_ticks == 0 then
                          for i = 1, #logo do dashboard.section.header.val[i] = "" end
                          row, col, needs_redraw = 1, 1, true
                      end
                  else
                      if row <= #logo then
                          local target_line = logo[row]
                          col = col + 1
                          if col > #target_line then col = #target_line end
                          dashboard.section.header.val[row] = target_line:sub(1, col)
                          needs_redraw = true
                          if col >= #target_line then
                              row, col = row + 1, 1
                              if row > #logo then pause_ticks = 60 end
                          end
                      end
                  end

                  local current_info = get_datetime()
                  if not info_typed then
                      info_col = info_col + 1
                      if info_col >= #current_info then
                          info_col, info_typed = #current_info, true
                      end
                      info_section.val[1] = current_info:sub(1, info_col)
                      needs_redraw = true
                  else
                      if info_section.val[1] ~= current_info then
                          info_section.val[1] = current_info
                          needs_redraw = true
                      end
                  end

                  if needs_redraw then pcall(vim.cmd.AlphaRedraw) end
                  vim.defer_fn(draw_frame, 12)
              end
              draw_frame()
          end,
      })
    end
  },

  -- Session management (auto-session): saves and restores tabs/buffers per project
  {
    "rmagatti/auto-session",
    event = "VeryLazy",
    cmd = { "AutoSession", "SessionSave", "SessionRestore", "SessionDelete", "SessionSearch" },
    config = function()
      local function clean_unnamed_buffers()
        -- Collect all buffers currently active in any window (normal or floating)
        local visible_bufs = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local b = vim.api.nvim_win_get_buf(win)
            visible_bufs[b] = true
          end
        end

        -- 1. Wipe only orphaned, listed empty placeholder/alpha buffers (never delete unlisted/plugin/nui/floating buffers)
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(bufnr) then
            local name = vim.api.nvim_buf_get_name(bufnr)
            local bt = vim.bo[bufnr].buftype
            local ft = vim.bo[bufnr].filetype
            local modified = vim.bo[bufnr].modified
            local listed = vim.bo[bufnr].buflisted
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            local is_empty = (line_count <= 1 and (vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or "") == "")

            -- Target Alpha dashboard buffer or empty unnamed listed buffer created during startup
            if ft == "alpha" then
              pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
            elseif listed and name == "" and bt == "" and is_empty and not modified and not visible_bufs[bufnr] then
              pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
            end
          end
        end

        -- 2. Close any orphaned blank window splits
        local file_wins = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              local name = vim.api.nvim_buf_get_name(buf)
              if ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "alpha" and name ~= "" then
                table.insert(file_wins, win)
              end
            end
          end
        end

        if #file_wins > 0 then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
              local cfg = vim.api.nvim_win_get_config(win)
              if cfg.relative == "" then
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.bo[buf].filetype
                local name = vim.api.nvim_buf_get_name(buf)
                if ft == "" and name == "" and not vim.bo[buf].modified then
                  pcall(vim.api.nvim_win_close, win, true)
                end
              end
            end
          end
        end
      end

      require("auto-session").setup({
        log_level = "error",
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        auto_restore = false, -- Loaded at VeryLazy (after VimEnter), so auto-restore can't run; sessions open from the dashboard
        auto_save = true,
        bypass_save_filetypes = { "alpha" },
        pre_save_cmds = {
          "NvimTreeClose",
          "AerialClose",
          function() pcall(vim.cmd, "Trouble close") end,
          clean_unnamed_buffers,
        },
        pre_restore_cmds = {
          clean_unnamed_buffers,
        },
        post_restore_cmds = {
          clean_unnamed_buffers,
          -- A session's name IS its project directory, so trust that over the `cd` line inside the file
          -- (older saves could carry another project's cd). Re-pin the root so later saves stay consistent.
          function(session_name)
            local root = vim.fs.normalize(session_name or "")
            if vim.fn.isdirectory(root) ~= 1 then root = vim.fn.getcwd() end
            vim.cmd("cd " .. vim.fn.fnameescape(root))
            _G._project_root = vim.fn.getcwd(-1, -1)
            vim.cmd("NvimTreeOpen " .. vim.fn.fnameescape(_G._project_root))
          end,
          clean_unnamed_buffers,
        },
      })

      -- auto-session names the session from the cwd at the moment it saves (VimLeavePre goes through here).
      -- Pin the cwd to the active project's root first, so a drifted cwd can't file one project's
      -- buffers under another project's name.
      local as = require("auto-session")
      local auto_save_session = as.auto_save_session
      as.auto_save_session = function(...)
        _G.Pin_Project_Root()
        return auto_save_session(...)
      end
    end,
  },

  -- Jump navigation (flash.nvim)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { search = { enabled = true } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Code outline sidebar (aerial.nvim)
  {
    "stevearc/aerial.nvim",
    event = "VeryLazy",
    cmd = { "AerialToggle", "AerialOpen", "AerialOpenAll", "AerialClose", "AerialCloseAll", "AerialNext", "AerialPrev" },
    dependencies = {
       "nvim-treesitter/nvim-treesitter",
       "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("aerial").setup({
        -- Try LSP first, fall back to treesitter (covers markdown, etc.)
        backends = { "lsp", "treesitter" },
        -- One outline sidebar that follows the focused split ("window" mode opens one sidebar per split,
        -- stacking several at the right edge and squeezing the code panes)
        attach_mode = "global",
        layout = {
          max_width = { 35, 0.25 },
          width = 35,
          min_width = 30,
          default_direction = "right",
          placement = "edge",
          preserve_equality = false,
          resize_to_content = false,
        },
        on_attach = function(bufnr)
          if _G.Fix_Sidebar_Widths then
            vim.schedule(_G.Fix_Sidebar_Widths)
          end
        end,
        -- Never opens on its own: <leader>a toggles it
        open_automatic = false,
        filter_kind = {
          _ = {
            "Class", "Constructor", "Enum", "Function", "Interface",
            "Module", "Method", "Struct", "Variable", "Constant",
            "Field", "Property", "TypeParameter",
          },
          markdown = false,
          help = false,
          tex = false,
          latex = false,
          plaintex = false,
        },
        icons = {
          Class = "󰠱 ", Function = "󰊕 ", Method = "󰆧 ",
          Struct = "󰙅 ", Interface = " ", Module = "󰏗 ",
          Variable = "󰀫 ", Constant = "󰏿 ", Field = "󰜢 ",
          Property = "󰖷 ", TypeParameter = "󰗴 ",
          String = "󰅳 ", File = "󰈙 ", Package = "󰏖 ",
          Namespace = "󰌗 ", Array = "󰅪 ", Object = "󰅩 ",
          Key = "󰌋 ", Number = "󰎠 ", Boolean = "󰨙 ",
        },
        show_guides = true,
        guides = {
          mid_item = "├─ ",
          last_item = "└─ ",
          nested_top = "│  ",
          whitespace = "   ",
        },
        -- Highlight & auto-scroll to the current symbol as the cursor moves
        highlight_on_hover = true,
        autojump = true,
        close_on_select = false,
        -- Keymaps inside the aerial window
        keymaps = {
          ["<CR>"] = "actions.tree_toggle",  -- Enter collapses/expands nodes
          ["o"] = "actions.jump",             -- 'o' to jump to symbol
        },
      })
    end
  },

  -- Fuzzy finder (fzf-lua)
  {
    "ibhagwan/fzf-lua",
    event = "VeryLazy",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf = require("fzf-lua")

      fzf.setup({
        winopts = {
          border = "rounded",
          preview = {
            border = "rounded",
            layout = "flex",
            horizontal = "right:50%",
          },
        },
        keymap = {
          builtin = {
            ["<Esc>"] = "hide",
            ["<M-u>"] = "hide",
            ["<M-U>"] = "hide",
            ["<M-j>"] = "down",
            ["<M-k>"] = "up",
            ["<M-h>"] = "preview-down",
            ["<M-l>"] = "preview-up",
          },
          fzf = {
            ["alt-j"] = "down",
            ["alt-k"] = "up",
            ["alt-h"] = "backward-char",
            ["alt-l"] = "forward-char",
            ["alt-w"] = "forward-word",
            ["alt-b"] = "backward-word",
            ["alt-u"] = "abort",
            ["alt-U"] = "abort",
            ["ctrl-j"] = "down",
            ["ctrl-k"] = "up",
            ["ctrl-u"] = "unix-line-discard",
            ["esc"] = "abort",
          },
        },
        files = {
          fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude node_modules --exclude .venv --exclude target",
        },
        grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        },
        fzf_opts = {
          ["--layout"] = "reverse",
          ["--marker"] = "●",
          ["--bind"] = "alt-j:down,alt-k:up,alt-h:backward-char,alt-l:forward-char,alt-u:abort,alt-w:forward-word,alt-b:backward-word,ctrl-j:down,ctrl-k:up",
        },
      })

      fzf.register_ui_select()
    end,
  },

  -- File explorer (nvim-tree)
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeCollapse", "NvimTreeRefresh" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local is_win = vim.fn.has("win32") == 1

      --- Safely delete a buffer without closing windows or corrupting sidebar layouts
      ---@param bufnr? integer Buffer number to delete (defaults to current buffer)
      ---@param force? boolean Force delete modified buffer
      local function safe_delete_buffer(bufnr, force)
        bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(bufnr) then return end

        -- 1. Try mini.bufremove first for graceful buffer detachment
        local ok_mini, mini_bufremove = pcall(require, "mini.bufremove")
        if ok_mini and mini_bufremove.delete then
          pcall(mini_bufremove.delete, bufnr, force or false)
        else
          -- Fallback: in every window showing this buffer, set a clean scratch buffer so the window is preserved
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
              local scratch = vim.api.nvim_create_buf(true, false)
              pcall(vim.api.nvim_win_set_buf, win, scratch)
            end
          end
          pcall(vim.api.nvim_buf_delete, bufnr, { force = force or false })
        end

        -- 2. Check if any normal code buffers remain open in visible windows
        local has_code_win = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" then
              local b = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_get_option_value("filetype", { buf = b })
              local name = vim.api.nvim_buf_get_name(b)
              if ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "alpha" and name ~= "" then
                has_code_win = true
                break
              end
            end
          end
        end

        -- 3. If no active code file is open, close Aerial so it doesn't monopolize the screen
        if not has_code_win then
          pcall(function() require("aerial").close() end)
        end

        -- 4. Reload NvimTree and preserve fixed sidebar widths
        local ok_tree, tree_api = pcall(require, "nvim-tree.api")
        if ok_tree and tree_api.tree.is_visible() then
          pcall(tree_api.tree.reload)
        end
        if _G.Fix_Sidebar_Widths then
          vim.schedule(_G.Fix_Sidebar_Widths)
        end
      end

      _G.Safe_Delete_Buffer = safe_delete_buffer

      --- Finds or creates a normal code window (outside NvimTree and Aerial sidebars)
      ---@return integer winid The window ID of the code window
      local function ensure_code_window()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
              if ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "alpha" then
                vim.api.nvim_set_current_win(win)
                return win
              end
            end
          end
        end

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
              if ft == "alpha" then
                vim.api.nvim_set_current_win(win)
                return win
              end
            end
          end
        end

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative == "" then
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
              if ft == "NvimTree" then
                vim.api.nvim_win_call(win, function()
                  vim.cmd("rightbelow vsplit")
                end)
                local new_win = vim.api.nvim_get_current_win()
                local scratch = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_win_set_buf(new_win, scratch)
                pcall(vim.api.nvim_set_option_value, "winfixwidth", false, { win = new_win })
                if _G.Fix_Sidebar_Widths then vim.schedule(_G.Fix_Sidebar_Widths) end
                return new_win
              end
            end
          end
        end

        vim.cmd("vsplit")
        local new_win = vim.api.nvim_get_current_win()
        local scratch = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(new_win, scratch)
        return new_win
      end

      _G.Ensure_Code_Window = ensure_code_window

      --- Asynchronously delete a single file or directory in the background
      ---@param target_path string Path to delete
      ---@param on_done? fun(success: boolean) Callback on completion
      local function async_delete_single(target_path, on_done)
        if not target_path or target_path == "" then return end
        local is_dir = vim.fn.isdirectory(target_path) == 1
        local cmd = {}

        if is_win then
          local win_path = target_path:gsub("/", "\\")
          if is_dir then
            cmd = { "cmd.exe", "/c", "rmdir", "/s", "/q", win_path }
          else
            cmd = { "cmd.exe", "/c", "del", "/f", "/q", win_path }
          end
        else
          cmd = { "rm", "-rf", target_path }
        end

        local name = vim.fn.fnamemodify(target_path, ":t")
        if name == "" then name = target_path end

        vim.notify(string.format("Deleting '%s' in background...", name), vim.log.levels.INFO, { title = "Async Delete" })

        vim.system(cmd, {}, function(obj)
          vim.schedule(function()
            if obj.code == 0 then
              vim.notify(string.format("Successfully deleted '%s'", name), vim.log.levels.INFO, { title = "Async Delete" })
              -- Clean up any open buffers matching the deleted path safely
              for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                  local buf_name = vim.api.nvim_buf_get_name(buf)
                  if buf_name ~= "" and (buf_name == target_path or (is_win and buf_name:lower() == target_path:lower())) then
                    safe_delete_buffer(buf, true)
                  end
                end
              end
            else
              local err = (obj.stderr and obj.stderr ~= "") and obj.stderr or ("Exit code " .. tostring(obj.code))
              vim.notify(string.format("Failed to delete '%s': %s", name, vim.trim(err)), vim.log.levels.ERROR, { title = "Async Delete" })
            end
            if on_done then on_done(obj.code == 0) end
          end)
        end)
      end

      --- Asynchronously delete multiple paths in parallel
      ---@param paths string[] List of paths to delete
      ---@param on_done? fun(all_success: boolean) Callback on completion
      local function async_delete_multiple(paths, on_done)
        if not paths or #paths == 0 then return end
        local total = #paths
        local completed = 0
        local has_error = false

        for _, p in ipairs(paths) do
          async_delete_single(p, function(success)
            completed = completed + 1
            if not success then has_error = true end
            if completed == total and on_done then
              on_done(not has_error)
            end
          end)
        end
      end

      -- Expose globally for use anywhere in Neovim
      _G.Async_Delete_Path = async_delete_single
      _G.Async_Delete_Paths = async_delete_multiple

      --- Custom delete action for NvimTree (replaces blocking synchronous deletion on 'd' and 'D')
      local function nvim_tree_async_remove(node)
        local api = require("nvim-tree.api")
        local marks = api.marks.list()
        local targets = {}

        if #marks > 0 then
          for _, m in ipairs(marks) do
            if m.absolute_path then
              table.insert(targets, m.absolute_path)
            end
          end
        else
          local target_node = node or api.tree.get_node_under_cursor()
          if target_node and target_node.absolute_path then
            table.insert(targets, target_node.absolute_path)
          end
        end

        if #targets == 0 then
          vim.notify("No file or folder selected for deletion", vim.log.levels.WARN, { title = "NvimTree" })
          return
        end

        local prompt_msg
        if #targets == 1 then
          local name = vim.fn.fnamemodify(targets[1], ":t")
          local is_dir = vim.fn.isdirectory(targets[1]) == 1
          prompt_msg = string.format("Delete %s '%s' in background? [y/N]: ", is_dir and "folder" or "file", name)
        else
          prompt_msg = string.format("Delete %d marked items in background? [y/N]: ", #targets)
        end

        vim.ui.input({ prompt = prompt_msg }, function(choice)
          if choice and (choice:lower() == "y" or choice:lower() == "yes") then
            async_delete_multiple(targets, function()
              if #marks > 0 then
                api.marks.clear()
              end
              api.tree.reload()
            end)
          end
        end)
      end

      require("nvim-tree").setup({
        sync_root_with_cwd = true, -- Follow cwd changes so tree matches project root
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set("n", "q", "<cmd>wincmd p<CR>", { buffer = bufnr, noremap = true, silent = true, desc = "Return to code" })

          -- Override blocking deletion keys ('d' and 'D') with async background execution
          vim.keymap.set("n", "d", nvim_tree_async_remove, { buffer = bufnr, noremap = true, silent = true, desc = "Async Delete (Background)" })
          vim.keymap.set("n", "D", nvim_tree_async_remove, { buffer = bufnr, noremap = true, silent = true, desc = "Async Delete (Background)" })
        end,
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = true,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = false,
            window_picker = {
              enable = false, -- Open files in the split that was focused last, instead of prompting for a letter
              picker = "default",
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
              exclude = {
                filetype = { "notify", "lazy", "mason", "qf", "diff", "fugitive", "fugitiveblame", "aerial", "NvimTree", "toggleterm", "trouble", "alpha" },
                buftype = { "nofile", "terminal", "help", "quickfix" },
              },
            },
          },
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 150,
          ignore_dirs = {
            "node_modules",
            "target",
            "%.git",
            "%.venv",
            "build",
            "dist",
            "__pycache__",
          },
          max_events = 0, -- Set to 0 (unlimited) to prevent disabling watcher during directory deletions on Windows; matches Linux default
        },
        renderer = {
          indent_markers = {
            enable = true,
            inline_arrows = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "├",
              bottom = "─",
              none = " ",
            },
          },
          highlight_git = true,
          highlight_opened_files = "all",
          highlight_diagnostics = true,
          icons = {
            show = {
              git = false, -- Disabled per request
            },
          },
        },
        filters = { dotfiles = false, git_ignored = false },
      })
    end,
  },

  -- Bufferline (transparent tab bar)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          -- The tab bar is shared by all splits: closing a tab closes the file and its pane (asking about
          -- unsaved changes), and clicking a tab whose file is already in a split jumps to that pane
          close_command = function(bufnr) vim.schedule(function() _G.Close_File(bufnr) end) end,
          right_mouse_command = function(bufnr) vim.schedule(function() _G.Close_File(bufnr) end) end,
          left_mouse_command = function(bufnr) _G.Show_Buffer(bufnr) end,
          offsets = {
            { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", separator = true },
            { filetype = "aerial", text = "Code Structure", highlight = "Directory", separator = true }
          }
        },
        highlights = {
          fill = { bg = "NONE" },
          background = { bg = "NONE" },
          tab = { bg = "NONE" },
          tab_selected = { bg = "NONE" },
          tab_close = { bg = "NONE" },
          close_button = { bg = "NONE" },
          close_button_visible = { bg = "NONE" },
          close_button_selected = { bg = "NONE" },
          -- Three tiers: focused pane (bright, bold, blue bar), shown in another split (mid, dim bar), hidden (comment)
          buffer_visible = { fg = "#a9b1d6", bg = "NONE" },
          buffer_selected = { fg = "#c0caf5", bg = "NONE", bold = true, italic = false },
          numbers = { bg = "NONE" },
          numbers_visible = { bg = "NONE" },
          numbers_selected = { bg = "NONE" },
          diagnostic = { bg = "NONE" },
          diagnostic_visible = { bg = "NONE" },
          diagnostic_selected = { bg = "NONE" },
          hint = { bg = "NONE" },
          hint_visible = { bg = "NONE" },
          hint_selected = { bg = "NONE" },
          info = { bg = "NONE" },
          info_visible = { bg = "NONE" },
          info_selected = { bg = "NONE" },
          warning = { bg = "NONE" },
          warning_visible = { bg = "NONE" },
          warning_selected = { bg = "NONE" },
          error = { bg = "NONE" },
          error_visible = { bg = "NONE" },
          error_selected = { bg = "NONE" },
          modified = { bg = "NONE" },
          modified_visible = { bg = "NONE" },
          modified_selected = { bg = "NONE" },
          separator = { fg = "#292e42", bg = "NONE" },
          separator_visible = { fg = "#292e42", bg = "NONE" },
          separator_selected = { fg = "#292e42", bg = "NONE" },
          indicator_selected = { fg = "#7aa2f7", bg = "NONE" },
          indicator_visible = { fg = "#3b4261", bg = "NONE" },
          pick_selected = { bg = "NONE" },
          pick_visible = { bg = "NONE" },
          pick = { bg = "NONE" },
          offset_separator = { fg = "#292e42", bg = "NONE" },
          trunc_marker = { bg = "NONE" },
        }
      })
    end
  },

  -- Syntax highlighting (treesitter)
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      require("nvim-treesitter").install({
        "javascript", "typescript", "tsx", "jsdoc",
        "c", "cpp", "python", "html",
        "css", "lua", "markdown", "rust", "toml",
        "go", "gomod", "gowork", "gosum", "gotmpl",
        "java", "latex", "bibtex",
      })

      -- The new nvim-treesitter (main branch) only installs parsers;
      -- it does NOT enable highlighting automatically.
      -- We must explicitly start treesitter highlighting for each buffer.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            -- Disable legacy regex syntax highlighting when treesitter is active
            vim.bo[args.buf].syntax = ""
          end
        end,
      })
    end,
  },

  -- Formatting (conform.nvim) with formatter errors surfaced as diagnostics and quickfix items
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    cmd = { "Format", "ConformErrors", "ConformInfo" },
    config = function()
      local conform = require("conform")
      local conform_ns = vim.api.nvim_create_namespace("conform_formatter_errors")

      --- Parse conform / formatter error messages into structured items
      ---@param err_str string Raw error string or conform log chunk
      ---@param default_bufnr? integer Current buffer number if available
      ---@return string formatter_name
      ---@return table[] parsed_errors
      local function parse_formatter_error(err_str, default_bufnr)
        local errors = {}
        local formatter_name = "formatter"

        local fmt_match = err_str:match("Formatter '([^']+)'")
        if fmt_match then
          formatter_name = fmt_match
        end

        local default_buf_name = (default_bufnr and vim.api.nvim_buf_is_valid(default_bufnr))
            and vim.api.nvim_buf_get_name(default_bufnr) or ""

        local lines = vim.split(err_str, "\r?\n", { trimempty = true })

        for _, raw_line in ipairs(lines) do
          local line = vim.trim(raw_line)
          -- Strip log timestamp and level prefix: e.g. "2026-08-17 08:27:03[ERROR] "
          line = line:gsub("^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d%[[%w_]+%]%s*", "")
          -- Strip Formatter '<name>' error: prefix
          local stripped_fmt, rest = line:match("^Formatter '([^']+)'%s*error:%s*(.*)")
          if stripped_fmt then
            formatter_name = stripped_fmt
            line = rest
          else
            local timeout_fmt = line:match("^Formatter '([^']+)'%s*timeout")
            if timeout_fmt then
              formatter_name = timeout_fmt
              line = "Formatter timed out"
            end
          end

          if line ~= "" then
            local parsed = nil

            -- Pattern 1: Black / Python "error: cannot format <filename>: Cannot parse: <line>:<col>"
            local black_file, black_l, black_c = line:match("error:%s*cannot format%s+([^:]+):%s*Cannot parse:%s*(%d+):(%d+)")
            if black_file then
              parsed = {
                file = (black_file ~= "" and black_file ~= "-") and black_file or (default_buf_name ~= "" and default_buf_name or "<standard input>"),
                lnum = tonumber(black_l),
                col = tonumber(black_c),
                msg = "Cannot parse syntax",
              }
            end

            -- Pattern 2: Ruff / Python "error: Failed to parse <filename>:<line>:<col>: <msg>"
            if not parsed then
              local ruff_file, ruff_l, ruff_c, ruff_msg = line:match("error:%s*Failed to parse%s+([^:]+):(%d+):(%d+):%s*(.+)")
              if ruff_file then
                parsed = {
                  file = ruff_file,
                  lnum = tonumber(ruff_l),
                  col = tonumber(ruff_c),
                  msg = ruff_msg,
                }
              end
            end

            -- Pattern 2: Standard input with path prefix or <standard input>:
            -- e.g. "C:\...\<standard input>:11:8: expected ')', found ':='"
            if not parsed then
              local stdin_prefix, l, c, msg = line:match("^(.-)[<\\]?standard input>?:(%d+):(%d+):%s*(.+)")
              if stdin_prefix and l and c and msg then
                parsed = {
                  file = default_buf_name ~= "" and default_buf_name or (stdin_prefix ~= "" and stdin_prefix or "<standard input>"),
                  lnum = tonumber(l),
                  col = tonumber(c),
                  msg = msg,
                }
              end
            end

            -- Pattern 3: Windows drive letter paths like "C:\path\to\file.go:11:8: msg" or "C:/path/file.py:11:8: msg"
            if not parsed then
              local drive, rest_f, l, c, msg = line:match("^([a-zA-Z]):[\\/](.-):(%d+):(%d+):%s*(.+)")
              if drive and rest_f and l and c and msg then
                parsed = {
                  file = drive .. ":\\" .. rest_f,
                  lnum = tonumber(l),
                  col = tonumber(c),
                  msg = msg,
                }
              end
            end

            -- Pattern 4: Generic "<file>:<line>:<col>: <msg>"
            if not parsed then
              local f, l, c, msg = line:match("^([^:]+):(%d+):(%d+):%s*(.+)")
              if f and l and c and msg and not f:match("^[a-zA-Z]$") then
                parsed = {
                  file = f,
                  lnum = tonumber(l),
                  col = tonumber(c),
                  msg = msg,
                }
              end
            end

            -- Pattern 5: Prettier SyntaxError: "[error] <file>: SyntaxError: <msg> (<line>:<col>)"
            if not parsed then
              local pf, pmsg, pl, pc = line:match("%[?error%]?%s*([^:]+):%s*(.-)%s*%((%d+):(%d+)%)")
              if pf and pl and pc then
                parsed = {
                  file = pf,
                  lnum = tonumber(pl),
                  col = tonumber(pc),
                  msg = pmsg,
                }
              end
            end

            -- Pattern 6: Python traceback "File "<stdin>", line 10" or "File "foo.py", line 10"
            if not parsed then
              local py_f, py_l = line:match('File "([^"]+)", line (%d+)')
              if py_f and py_l then
                parsed = {
                  file = py_f,
                  lnum = tonumber(py_l),
                  col = 1,
                  msg = line,
                }
              end
            end

            -- Pattern 7: Line without column "<file>:<line>: <msg>"
            if not parsed then
              local f, l, msg = line:match("^([^:]+):(%d+):%s*(.+)")
              if f and l and msg and not f:match("^[a-zA-Z]$") then
                parsed = {
                  file = f,
                  lnum = tonumber(l),
                  col = 1,
                  msg = msg,
                }
              end
            end

            -- Fallback if line has error content
            local l_low = line:lower()
            if not parsed and (l_low:find("error") or l_low:find("fail") or l_low:find("timeout") or l_low:find("timed out") or l_low:find("syntax") or l_low:find("warn")) then
              parsed = {
                file = default_buf_name ~= "" and default_buf_name or "Conform",
                lnum = 1,
                col = 1,
                msg = line,
              }
            end

            if parsed then
              if parsed.file:find("<standard input>") or parsed.file:find("stdin") or parsed.file == "" then
                parsed.file = default_buf_name ~= "" and default_buf_name or parsed.file
              elseif default_buf_name ~= "" and (parsed.file == default_buf_name or default_buf_name:find(parsed.file, 1, true)) then
                parsed.file = default_buf_name
              end
              parsed.formatter = formatter_name
              table.insert(errors, parsed)
            end
          end
        end

        return formatter_name, errors
      end

      --- Clear buffer diagnostics from conform
      local function clear_conform_errors(bufnr)
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          vim.diagnostic.reset(conform_ns, bufnr)
        end
      end

      --- Dispatch conform errors to diagnostics, quickfix list, and notification
      local function handle_conform_errors(err_str, bufnr)
        if not err_str or err_str == "" then return end
        if err_str == "No formatters available for buffer" or err_str:find("No formatters available") or err_str:find("buffer was deleted") then
          return
        end
        local formatter, parsed_errors = parse_formatter_error(err_str, bufnr)

        if #parsed_errors == 0 then
          vim.notify(err_str, vim.log.levels.ERROR, { title = "Conform: " .. formatter })
          return
        end

        local qf_items = {}
        local diagnostics = {}
        local notif_lines = {}

        for _, item in ipairs(parsed_errors) do
          if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
            local total_lines = vim.api.nvim_buf_line_count(bufnr)
            local lnum = math.min(math.max(1, item.lnum or 1), total_lines) - 1
            local col = math.max(0, (item.col or 1) - 1)
            table.insert(diagnostics, {
              bufnr = bufnr,
              lnum = lnum,
              col = col,
              severity = vim.diagnostic.severity.ERROR,
              source = "Conform (" .. formatter .. ")",
              message = item.msg,
            })
          end

          table.insert(qf_items, {
            bufnr = bufnr or 0,
            filename = (item.file ~= "" and item.file ~= "<standard input>") and item.file or (bufnr and vim.api.nvim_buf_get_name(bufnr) or "Conform"),
            lnum = item.lnum or 1,
            col = item.col or 1,
            text = string.format("[%s] %s", formatter, item.msg),
            type = "E",
          })

          table.insert(notif_lines, string.format("  • Line %d:%d: %s", item.lnum or 1, item.col or 1, item.msg))
        end

        -- Publish diagnostics on buffer
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) and #diagnostics > 0 then
          vim.diagnostic.set(conform_ns, bufnr, diagnostics)
        end

        -- Update Quickfix list
        if #qf_items > 0 then
          vim.fn.setqflist(qf_items, "r")
          vim.fn.setqflist({}, "a", { title = "Conform Formatter Errors" })
        end

        -- Show notification with real error details
        local notif_body = string.format("Formatter '%s' failed (%d error%s):\n%s", formatter, #parsed_errors, #parsed_errors > 1 and "s" or "", table.concat(notif_lines, "\n"))
        vim.notify(notif_body, vim.log.levels.ERROR, { title = "Conform: " .. formatter })
      end

      --- Format buffer with error handling
      local function format_buffer(bufnr, opts)
        bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
        opts = opts or {}
        local timeout = vim.fn.has("win32") == 1 and 3000 or 1000
        conform.format(vim.tbl_extend("force", {
          bufnr = bufnr,
          async = false,
          lsp_format = "fallback",
          timeout_ms = timeout,
          quiet = true,
        }, opts), function(err, did_edit)
          if err then
            handle_conform_errors(err, bufnr)
          else
            clear_conform_errors(bufnr)
            if did_edit then
              vim.notify("Formatted buffer successfully", vim.log.levels.INFO, { title = "Conform" })
            end
          end
        end)
      end

      conform.setup({
        formatters_by_ft = {
          javascript = { "oxfmt" },
          typescript = { "oxfmt" },
          javascriptreact = { "oxfmt" },
          typescriptreact = { "oxfmt" },
          css = { "oxfmt" },
          html = { "oxfmt" },
          json = { "oxfmt" },
          yaml = { "oxfmt" },
          markdown = { "oxfmt" },
          python = { "black" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          rust = { "rustfmt" },
          go = { "gofmt" },
          java = { "google-java-format" },
          toml = { "taplo" },
        },
        notify_on_error = false,
        format_on_save = function(bufnr)
          local timeout = vim.fn.has("win32") == 1 and 3000 or 1000
          return {
            timeout_ms = timeout,
            lsp_format = "fallback",
            quiet = true,
          }, function(err)
            if err then
              handle_conform_errors(err, bufnr)
            else
              clear_conform_errors(bufnr)
            end
          end
        end,
        formatters = {
          oxfmt = {
            command = "oxfmt",
            args = { "--stdin-filepath", "$FILENAME" },
            stdin = true,
          },
          ["clang-format"] = { prepend_args = { "-style={UseTab: Always, TabWidth: 4, IndentWidth: 4}" } },
          rustfmt = { prepend_args = { "--config", "hard_tabs=true,tab_spaces=4" } },
        },
      })

      -- Use conform as the formatexpr for gq formatting
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Interactive navigation inside :ConformInfo floating window
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "conform-info",
        desc = "ConformInfo interactive error navigation & quickfix export",
        callback = function(args)
          local buf = args.buf
          -- Press <CR> on any error line in ConformInfo to jump to the source file & line
          vim.keymap.set("n", "<CR>", function()
            local line = vim.api.nvim_get_current_line()
            local _, parsed = parse_formatter_error(line, nil)
            if parsed and #parsed > 0 then
              local item = parsed[1]
              if item.file and item.file ~= "" and item.file ~= "Conform" and item.file ~= "<standard input>" then
                vim.cmd("close")
                vim.cmd("edit " .. vim.fn.fnameescape(item.file))
                pcall(vim.api.nvim_win_set_cursor, 0, { math.max(1, item.lnum or 1), math.max(0, (item.col or 1) - 1) })
              else
                vim.notify("Cannot jump: file path is stdin or not specified", vim.log.levels.WARN, { title = "ConformInfo" })
              end
            else
              vim.notify("No error line found under cursor", vim.log.levels.INFO, { title = "ConformInfo" })
            end
          end, { buffer = buf, silent = true, desc = "Jump to error under cursor" })

          -- Press 'E' in ConformInfo to load all errors into Quickfix
          vim.keymap.set("n", "E", function()
            local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local content = table.concat(buf_lines, "\n")
            local _, parsed = parse_formatter_error(content, nil)
            if #parsed > 0 then
              local qf_list = {}
              for _, it in ipairs(parsed) do
                table.insert(qf_list, {
                  filename = (it.file ~= "" and it.file ~= "<standard input>") and it.file or "Conform",
                  lnum = it.lnum or 1,
                  col = it.col or 1,
                  text = string.format("[%s] %s", it.formatter or "formatter", it.msg),
                  type = "E",
                })
              end
              vim.fn.setqflist(qf_list, "r")
              vim.fn.setqflist({}, "a", { title = "ConformInfo Errors (" .. #qf_list .. ")" })
              vim.cmd("copen")
              vim.notify(string.format("Exported %d errors to Quickfix", #qf_list), vim.log.levels.INFO, { title = "ConformInfo" })
            else
              vim.notify("No error lines found in ConformInfo", vim.log.levels.INFO, { title = "ConformInfo" })
            end
          end, { buffer = buf, silent = true, desc = "Export all errors to Quickfix" })
        end,
      })

      -- User Command: Format current buffer or visual selection
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line and end_line:len() or 0 },
          }
        end
        format_buffer(0, { range = range })
      end, { range = true, desc = "Format buffer or selection with Conform error handling" })

      -- User Command: Load recent conform.log errors into Quickfix list
      vim.api.nvim_create_user_command("ConformErrors", function()
        local log = require("conform.log")
        local logfile = log.get_logfile()
        if vim.fn.filereadable(logfile) ~= 1 then
          vim.notify("No conform.log found at: " .. logfile, vim.log.levels.INFO, { title = "Conform" })
          return
        end
        local f = io.open(logfile, "r")
        if not f then
          vim.notify("Failed to open conform.log", vim.log.levels.ERROR, { title = "Conform" })
          return
        end
        local content = f:read("*a")
        f:close()

        local curr_buf = vim.api.nvim_get_current_buf()
        local _, parsed = parse_formatter_error(content, curr_buf)
        if #parsed == 0 then
          vim.notify("No errors found in conform.log", vim.log.levels.INFO, { title = "Conform" })
          return
        end

        local qf_list = {}
        for _, it in ipairs(parsed) do
          table.insert(qf_list, {
            filename = (it.file ~= "" and it.file ~= "<standard input>") and it.file or (curr_buf and vim.api.nvim_buf_get_name(curr_buf) or "Conform"),
            lnum = it.lnum or 1,
            col = it.col or 1,
            text = string.format("[%s] %s", it.formatter or "formatter", it.msg),
            type = "E",
          })
        end

        vim.fn.setqflist(qf_list, "r")
        vim.fn.setqflist({}, "a", { title = "Conform Log Errors (" .. #qf_list .. ")" })
        vim.cmd("copen")
      end, { desc = "Load errors from conform.log into Quickfix list" })

      -- Keymaps for formatting and error inspection
      vim.keymap.set({ "n", "v" }, "<leader>cf", function() vim.cmd("Format") end, { noremap = true, silent = true, desc = "Conform: Format Buffer" })
      vim.keymap.set("n", "<leader>ce", "<cmd>ConformErrors<CR>", { noremap = true, silent = true, desc = "Conform: View Formatter Errors (Quickfix)" })
    end,
  },

  -- Completion (blink.cmp)
  {
    "saghen/blink.cmp",
    event = "VeryLazy",
    version = "*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<Up>"] = { "fallback" },
        ["<Down>"] = { "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          border = "rounded",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
          },
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- Diagnostics panel (trouble.nvim)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { modes = { diagnostics = { auto_preview = true } } },
    keys = {
      {
        "<leader>xx",
        function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble.close()
            return
          end

          local diags = vim.diagnostic.get(0)
          if #diags == 0 then
            vim.notify("No diagnostics in active file", vim.log.levels.INFO, { title = "Diagnostics" })
            return
          end

          trouble.open({ mode = "diagnostics", focus = true })
        end,
        desc = "Diagnostics / Errors (Trouble)",
      },
    },
  },

  -- =========================================================================
  -- DEBUG ADAPTER PROTOCOL (DAP) & GO DEBUGGING (Delve)
  -- =========================================================================
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapStepOver", "DapStepInto", "DapStepOut", "DapTerminate" },
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_go = require("dap-go")
      local dap_vt = require("nvim-dap-virtual-text")

      -- Setup inline virtual text for variable inspection during debugging
      dap_vt.setup({
        commented = true,
        highlight_changed_variables = true,
        show_stop_reason = true,
      })

      -- Setup DAP UI with rich debugger layout
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 10,
          },
        },
        floating = {
          border = "rounded",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
      })

      -- Helper to find the actual delve binary executable (handles Windows vs Unix, GOPATH, ~/go/bin, and system PATH)
      local function get_delve_path()
        local is_win = vim.fn.has("win32") == 1
        local ext = is_win and ".exe" or ""

        -- 1. Check ~/go/bin
        local go_bin = vim.fs.joinpath(vim.fn.expand("~/go/bin"), "dlv" .. ext)
        if vim.uv.fs_stat(go_bin) then
          return go_bin
        end

        -- 3. Check GOPATH/bin if set
        if vim.env.GOPATH then
          local gopath_bin = vim.fs.joinpath(vim.env.GOPATH, "bin", "dlv" .. ext)
          if vim.uv.fs_stat(gopath_bin) then
            return gopath_bin
          end
        end

        -- 4. Check system exepath (if it's an .exe or binary directly)
        local sys_path = vim.fn.exepath("dlv" .. ext)
        if sys_path ~= "" and not sys_path:lower():match("%.cmd$") and not sys_path:lower():match("%.bat$") then
          return sys_path
        end

        -- 5. Fallback
        return is_win and "dlv.exe" or "dlv"
      end

      -- Helper to detect Go project / module root (where go.mod or .git resides)
      local function get_go_project_root(bufnr)
        local buf_name = bufnr and vim.api.nvim_buf_get_name(bufnr) or vim.api.nvim_buf_get_name(0)
        local start_dir = (buf_name ~= "") and vim.fs.dirname(buf_name) or vim.fn.getcwd()
        local root = vim.fs.root(start_dir, { "go.mod", "go.work", ".git" })
        return root or start_dir
      end

      -- Sanitize Windows path artifacts like "./C:/..." produced by treesitter test runner
      local function sanitize_go_program_path(prog)
        if not prog or prog == "" or prog == "${file}" or prog == "${fileDirname}" then
          return prog
        end
        prog = prog:gsub("^%./([a-zA-Z]:)", "%1"):gsub("^%.\\([a-zA-Z]:)", "%1")
        return prog
      end

      -- Setup DAP for Go (delve integration)
      dap_go.setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        delve = {
          path = get_delve_path(),
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
          detached = vim.fn.has("win32") == 0,
        },
      })

      -- Directly configure DAP adapter for Go with dynamic root and Delve binary resolution
      dap.adapters.go = function(callback, client_config)
        local dlv_path = get_delve_path()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local start_dir = (buf_name ~= "") and vim.fs.dirname(buf_name) or vim.fn.getcwd()
        local root = (client_config and client_config.cwd) or vim.fs.root(start_dir, { "go.mod", "go.work", ".git" }) or start_dir

        if client_config then
          if not client_config.cwd then
            client_config.cwd = root
          end
          if client_config.program then
            client_config.program = sanitize_go_program_path(client_config.program)
          end
        end

        callback({
          type = "server",
          port = "${port}",
          executable = {
            command = dlv_path,
            args = { "dap", "-l", "127.0.0.1:${port}" },
            cwd = root,
            detached = vim.fn.has("win32") == 0,
          },
          options = {
            initialize_timeout_sec = 20,
          },
        })
      end

      -- Open UI automatically when debug session starts
      -- Kept open after execution terminates so variables & stack traces can be inspected
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      -- Custom signs & highlights for breakpoints and execution pointer
      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "🔘", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    end,
  },

  -- Jupyter: inline cell execution and output (molten-nvim)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    ft = { "python", "ipynb" },
    cmd = { "MoltenInit", "MoltenEvaluateCell", "MoltenReevaluateCell", "MoltenDelete", "MoltenShowOutput" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_virt_lines = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_cover_empty_lines = true
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<CR>", desc = "Initialize Jupyter Kernel" },
      { "<leader>rc", "<cmd>MoltenEvaluateCell<CR>", desc = "Evaluate Cell Inline" },
      { "<leader>rd", "<cmd>MoltenDelete<CR>", desc = "Delete Cell Output" },
      { "<leader>ro", "<cmd>MoltenShowOutput<CR>", desc = "Show Output Float Window" },
      { "<leader>rr", "<cmd>MoltenReevaluateCell<CR>", desc = "Re-evaluate Cell" },
      { "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>", mode = "v", desc = "Evaluate Visual Selection Inline" },
    },
  },

  { "echasnovski/mini.bufremove", version = "*", event = "VeryLazy", config = function() require("mini.bufremove").setup() end },
  { "mechatroner/rainbow_csv", ft = { "csv", "tsv" }, cmd = { "RainbowDelim", "RainbowDelimSimple", "RainbowDelimQuoted", "NoRainbowDelim" } },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local tokyonight_theme = require("lualine.themes.tokyonight")
      for _, mode in pairs(tokyonight_theme) do
        if type(mode) == "table" and mode.c then
          mode.c.bg = "NONE"
        end
      end
      if tokyonight_theme.inactive then
        if tokyonight_theme.inactive.a then tokyonight_theme.inactive.a.bg = "NONE" end
        if tokyonight_theme.inactive.b then tokyonight_theme.inactive.b.bg = "NONE" end
        if tokyonight_theme.inactive.c then tokyonight_theme.inactive.c.bg = "NONE" end
      end

      require("lualine").setup({
        options = {
          theme = tokyonight_theme,
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        }
      })
    end,
  },
  { "echasnovski/mini.pairs", version = "*", event = "VeryLazy", config = function() require("mini.pairs").setup() end },
  { "folke/which-key.nvim", event = "VeryLazy", config = function() require("which-key").setup({ delay = 500, win = { border = "rounded" } }) end },
  { "lewis6991/gitsigns.nvim", event = "VeryLazy", config = function() require("gitsigns").setup({ current_line_blame = false, max_file_length = 20000, current_line_blame_opts = { delay = 500, virt_text_pos = 'eol' } }) end,
    keys = { { "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "Toggle Line Blame" } },
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec" },
    config = function()
      require("toggleterm").setup({
        size = 20, open_mapping = [[<c-\>]], direction = "float", shade_terminals = false, float_opts = { border = "curved" },
        on_open = function(term)
          if _G.Update_Term_Winbar then _G.Update_Term_Winbar(term.window) end
          vim.cmd("startinsert!")
        end,
      })
    end,
  },

  -- Image viewer (image.nvim, Kitty graphics protocol); loads only when an image file is opened
  {
    "3rd/image.nvim",
    event = {
      "BufReadCmd *.png", "BufReadCmd *.jpg", "BufReadCmd *.jpeg", "BufReadCmd *.gif", "BufReadCmd *.webp",
      "BufReadCmd *.avif", "BufReadCmd *.bmp", "BufReadCmd *.tiff", "BufReadCmd *.ico", "BufReadCmd *.svg",
      "BufReadPre *.png", "BufReadPre *.jpg", "BufReadPre *.jpeg", "BufReadPre *.gif", "BufReadPre *.webp",
      "BufReadPre *.avif", "BufReadPre *.bmp", "BufReadPre *.tiff", "BufReadPre *.ico", "BufReadPre *.svg",
    },
    config = function()
      require("image").setup({
        backend = "kitty",
        processor = "magick_cli",
        max_width_window_percentage = 90,
        max_height_window_percentage = 80,
        window_overlap_clear_enabled = false,
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        ignore_download_error = true,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.bmp", "*.tiff", "*.ico", "*.svg" },
      })

      -- Keymaps for image buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "image_nvim",
        callback = function(args)
          vim.keymap.set("n", "q", "<cmd>bdelete!<CR>", { buffer = args.buf, silent = true, desc = "Close Image" })
          vim.keymap.set("n", "o", function()
            local path = vim.api.nvim_buf_get_name(args.buf)
            if path ~= "" then vim.ui.open(path) end
          end, { buffer = args.buf, silent = true, desc = "Open in OS Viewer" })
        end,
      })
    end,
  },

  -- Markdown rendering in the buffer (render-markdown.nvim)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        enabled = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = { enabled = true },
      bullet = { enabled = true },
    },
    keys = {
      { "<leader>mp", "<cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Toggle Markdown Render" },
    },
  },

  -- =========================================================================
  -- UI: APPEARANCE AND MOTION
  -- =========================================================================

  -- Animated cursor trail, tuned for a 240Hz display (toggle: <leader>uc)
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    keys = { { "<leader>uc", "<cmd>SmearCursorToggle<CR>", desc = "Toggle Cursor Smear" } },
    opts = {
      cursor_color = "#7aa2f7",
      time_interval = 4, -- ~240 FPS render interval matching 240Hz display
      stiffness = 0.2, -- Gentle, fluid movement across frames instead of instant snap
      trailing_stiffness = 0.12, -- Soft lagging tail for a visible smooth glide
      damping = 0.65, -- Natural physical momentum
      trailing_exponent = 3,
      anticipation = 0.1,
      distance_stop_animating = 0.1,
      delay_event_to_smear = 0,
      delay_after_key = 0,
      color_levels = 32,
      legacy_computing_symbols_support = true,
      legacy_computing_symbols_support_vertical_bars = true,
      use_diagonal_blocks = true,
      smear_between_neighbor_lines = true,
      smear_between_buffers = true,
      scroll_buffer_space = true,
    },
  },

  -- Rounded floating input and select dialogs
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        border = "rounded",
        mappings = {
          n = { ["<Esc>"] = "Close", ["<CR>"] = "Confirm" },
          i = { ["<Esc>"] = "Close", ["<CR>"] = "Confirm", ["<Up>"] = "HistoryPrev", ["<Down>"] = "HistoryNext" },
        }
      },
      select = { enabled = false }, -- fzf-lua's register_ui_select() handles vim.ui.select
    },
  },

  -- Indent guides with an animated current-scope line
  {
    "echasnovski/mini.indentscope",
    version = "*",
    event = "VeryLazy",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
      draw = {
        delay = 50,
        animation = function(s, n)
          local ok, mini = pcall(require, "mini.indentscope")
          if ok and mini.gen_animation then
            return mini.gen_animation.quadratic({ easing = "out", duration = 120, unit = "step" })(s, n)
          end
          return 10
        end,
      },
    },
    config = function(_, opts)
      require("mini.indentscope").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "alpha",
          "dashboard",
          "fzf",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "NvimTree",
          "notify",
          "toggleterm",
          "trouble",
          "checkhealth",
          "aerial",
          "dapui_scopes",
          "dapui_breakpoints",
          "dapui_stacks",
          "dapui_watches",
          "dapui_console",
          "dap-repl",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  -- Breadcrumb winbar
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
  },

  -- Floating cmdline, notifications, and messages
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  -- Inline color swatches for color codes
  {
    "brenoprata10/nvim-highlight-colors",
    event = "VeryLazy",
    opts = {
      render = "background",
      enable_named_colors = true,
    },
  },

  -- Scrollbar showing diagnostics and git changes (toggle: <leader>us)
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    keys = { { "<leader>us", "<cmd>ScrollbarToggle<CR>", desc = "Toggle Scrollbar" } },
    opts = {
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        search = false,
      },
    },
  },

}, {
  checker = { enabled = true, notify = false, frequency = 86400 },
  change_detection = { notify = false },
  rocks = { enabled = false }
})

-- =========================================================================
-- 3. LSP CONFIGURATION
-- =========================================================================

-- Completion capabilities are registered by blink.cmp itself (plugin/blink-cmp.lua) when it loads

-- TypeScript / JavaScript (vtsls)
vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  settings = {
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
})

-- Oxlint linting
vim.lsp.config("oxlint", {
  cmd = { "oxlint", "--lsp" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
    "astro",
  },
  root_markers = {
    ".oxlintrc.json",
    ".oxlintrc.jsonc",
    "oxlint.config.ts",
    "package.json",
    ".git",
  },
})

vim.lsp.config("clangd", {
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
})
local basedpyright_analysis = {
  autoSearchPaths = true,
  useLibraryCodeForTypes = true,
  diagnosticMode = "openFilesOnly",
  typeCheckingMode = "standard",
  reportMissingTypeStubs = "none",
  reportUnknownMemberType = "none",
  reportUnusedCallResult = "none",
  reportUnknownArgumentType = "none",
  reportUnknownVariableType = "none",
}

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json", ".venv", ".git" },
  before_init = function(_, config)
    local root = config.root_dir or _G._project_root or vim.fn.getcwd()
    local venv = vim.fs.joinpath(root, ".venv")
    if vim.fn.isdirectory(venv) == 1 then
      local is_win = vim.fn.has("win32") == 1
      local py_candidates = {
        vim.fs.joinpath(venv, "Scripts", "python.exe"),
        vim.fs.joinpath(venv, "bin", "python"),
        vim.fs.joinpath(venv, "Scripts", "python"),
        vim.fs.joinpath(venv, "bin", "python.exe"),
      }
      local python_path = is_win and py_candidates[1] or py_candidates[2]
      for _, cand in ipairs(py_candidates) do
        if vim.uv.fs_stat(cand) then
          python_path = cand
          break
        end
      end

      config.settings = config.settings or {}
      config.settings.python = config.settings.python or {}
      config.settings.python.pythonPath = python_path
      config.settings.python.venvPath = root
      config.settings.python.venv = ".venv"
    end
  end,
  settings = {
    basedpyright = {
      analysis = basedpyright_analysis,
    },
    python = {
      analysis = basedpyright_analysis,
    },
  },
})
vim.lsp.config("rust_analyzer", { cmd = { "rust-analyzer" }, filetypes = { "rust" }, root_markers = { "Cargo.toml", "rust-project.json", ".git" }, settings = { ["rust-analyzer"] = { checkOnSave = true, check = { command = "check" }, cargo = { allFeatures = true } } } })

-- Go (gopls, resolved from GOPATH; avoids the Mason copy, which Windows Device Guard can block)
local function get_gopls_cmd()
  local candidates = {
    vim.fn.expand("~/go/bin/gopls.exe"),
    vim.fn.expand("~/go/bin/gopls"),
    "C:\\Program Files\\Go\\bin\\gopls.exe",
    "gopls",
  }
  for _, cand in ipairs(candidates) do
    if vim.fn.filereadable(cand) == 1 or cand == "gopls" then
      return { cand }
    end
  end
  return { "gopls" }
end

vim.lsp.config("gopls", {
  cmd = get_gopls_cmd(),
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.work", ".git" },
  settings = {
    gopls = { completeUnimported = true, usePlaceholders = true, analyses = { unusedparams = true, unusedvariable = true, unusedwrite = true }, semanticTokens = true },
  },
})

-- Java (jdtls)
vim.lsp.config("jdtls", {
  cmd = { "jdtls" },
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git", "settings.gradle", "settings.gradle.kts" },
  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
        },
        filteredTypes = { "com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*", "sun.*" },
      },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
    },
  },
})

-- LaTeX (texlab)
vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "plaintex", "bib" },
  root_markers = { ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml", ".git" },
})

-- TOML (taplo)
vim.lsp.config("taplo", {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { ".taplo.toml", "taplo.toml", ".git" },
})

vim.lsp.enable("vtsls")
vim.lsp.enable("oxlint")
vim.lsp.enable("clangd")
vim.lsp.enable("basedpyright")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("gopls")
vim.lsp.enable("jdtls")
vim.lsp.enable("texlab")
vim.lsp.enable("taplo")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspAttachConfig", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end
    local bufnr = args.buf
    -- Stop LSP clients from attaching to large buffers (see BinaryGuard)
    if vim.b[bufnr].large_file then
      vim.schedule(function() vim.lsp.buf_detach_client(bufnr, args.data.client_id) end)
      return
    end
    local opts = { buffer = bufnr, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, { buffer = bufnr, silent = true, desc = "LSP Go to Definition" })

    local function show_references()
      local ok, fzf = pcall(require, "fzf-lua")
      if ok then
        fzf.lsp_references()
      else
        vim.lsp.buf.references()
      end
    end

    vim.keymap.set("n", "gr", show_references, { buffer = bufnr, silent = true, desc = "LSP Go to References (fzf-lua)" })
    vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = bufnr, silent = true, desc = "LSP Hover Documentation" })
    vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, { buffer = bufnr, silent = true, desc = "LSP Hover Documentation" })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, silent = true, desc = "Code Action" })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, silent = true, desc = "Rename Symbol" })
  end,
})

-- =========================================================================
-- 4. CORE EDITOR SETTINGS, AUTOCMDS, AND GUARDS
-- =========================================================================
vim.opt.termguicolors = true
vim.opt.equalalways = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.guicursor = "a:blinkon0"
vim.opt.confirm = true
vim.opt.clipboard = "unnamedplus"
vim.opt.keymodel = "startsel,stopsel"
vim.opt.selectmode = "key,mouse"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 300   -- Fast CursorHold trigger for diagnostic popups
vim.opt.undofile = true    -- Persist undo history across sessions
vim.opt.undolevels = 10000
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.inccommand = "split"
vim.opt.mouse = "a"
vim.opt.fillchars:append({ eob = " " })
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.autoread = true
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal" } -- Exclude 'blank' to avoid saving empty/untitled placeholder windows

-- Python Indentation (PEP 8: 4-space indent, 4 additional spaces for continuation lines)
vim.g.python_indent = {
  open_paren = "shiftwidth()",
  nested_paren = "shiftwidth()",
  ["continue"] = "shiftwidth()",
  closed_paren_align_last_line = false,
}
vim.g.pyindent_open_paren = "shiftwidth()"
vim.g.pyindent_nested_paren = "shiftwidth()"
vim.g.pyindent_continue = "shiftwidth()"

vim.diagnostic.config({
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = { " Diagnostics", "Bold" },
    prefix = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        return "󰅚 ", "DiagnosticSignError"
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        return "󰀦 ", "DiagnosticSignWarn"
      elseif diagnostic.severity == vim.diagnostic.severity.INFO then
        return "󰋼 ", "DiagnosticSignInfo"
      else
        return "󰌵 ", "DiagnosticSignHint"
      end
    end,
  },
  virtual_text = { severity = vim.diagnostic.severity.ERROR },
  signs = true,
  underline = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Buffers where idle/focus autocmds (diagnostic float, checktime) must not run
local ignored_ft = {
  [""] = true, NvimTree = true, aerial = true, toggleterm = true,
  trouble = true, alpha = true, lazy = true, mason = true,
}
local function is_ignored_buffer()
  local ft = vim.bo.filetype
  return vim.bo.buftype ~= "" or ignored_ft[ft] or ft:find("^dap") ~= nil
end

-- Show the diagnostic float when the cursor rests on a line that has diagnostics
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("DiagnosticFloatOnHold", { clear = true }),
  pattern = "*",
  callback = function()
    if is_ignored_buffer() then return end

    local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(0, { lnum = lnum })

    if #diagnostics > 0 then
      vim.diagnostic.open_float(nil, {
        focus = false,
        scope = "line",
      })
    end
  end,
})

-- Keep NvimTree and Aerial at consistent widths across splits and resizes
local function fix_sidebar_widths()
  local tree_win = nil
  local aerial_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" then
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == "NvimTree" then
          tree_win = win
        elseif ft == "aerial" then
          aerial_win = win
        end
      end
    end
  end

  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    pcall(vim.api.nvim_win_set_width, tree_win, 35)
    pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = tree_win })
  end
  if aerial_win and vim.api.nvim_win_is_valid(aerial_win) then
    pcall(vim.api.nvim_win_set_width, aerial_win, 35)
    pcall(vim.api.nvim_set_option_value, "winfixwidth", true, { win = aerial_win })
  end
end

_G.Fix_Sidebar_Widths = fix_sidebar_widths

vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = vim.api.nvim_create_augroup("SidebarWidths", { clear = true }),
  desc = "Preserve fixed sidebar width ratio for NvimTree and Aerial",
  callback = function()
    vim.schedule(fix_sidebar_widths)
  end,
})

-- Layout guard: when the last normal buffer closes, keep the sidebars from taking over
-- the layout or being corrupted (NvimTree in particular)
local layout_guard_group = vim.api.nvim_create_augroup("SafeBufferLayoutGuard", { clear = true })
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
  group = layout_guard_group,
  callback = function()
    vim.schedule(function()
      local has_normal_win = false
      local aerial_win = nil
      local tree_win = nil

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative == "" then
            local b = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = b })
            if ft == "NvimTree" then
              tree_win = win
            elseif ft == "aerial" then
              aerial_win = win
            elseif ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "alpha" then
              has_normal_win = true
            end
          end
        end
      end

      -- If all normal windows were destroyed, collapse Aerial immediately
      if not has_normal_win and aerial_win and vim.api.nvim_win_is_valid(aerial_win) then
        pcall(function() require("aerial").close() end)
      end

      -- If NvimTree is left with no normal window beside it, recreate the code window
      -- so opening files never splits or crushes NvimTree
      if not has_normal_win and tree_win and vim.api.nvim_win_is_valid(tree_win) then
        vim.api.nvim_win_call(tree_win, function()
          vim.cmd("rightbelow vsplit")
          local new_win = vim.api.nvim_get_current_win()
          local scratch = vim.api.nvim_create_buf(true, false)
          vim.api.nvim_win_set_buf(new_win, scratch)
        end)
      end

      if _G.Fix_Sidebar_Widths then
        _G.Fix_Sidebar_Widths()
      end
    end)
  end,
})

-- =========================================================================
-- EXTERNAL FILE CHANGES AND DELETIONS
-- =========================================================================
local deleted_buffers_notified = {}
local external_file_group = vim.api.nvim_create_augroup("ExternalFileWatch", { clear = true })

-- Handle files modified or deleted on disk while they are open
vim.api.nvim_create_autocmd("FileChangedShell", {
  group = external_file_group,
  pattern = "*",
  callback = function(args)
    local bufnr = args.buf
    local file = args.file
    local fname = vim.fn.fnamemodify(file, ":t")

    if vim.v.fcs_reason == "deleted" then
      -- An empty v:fcs_choice tells Neovim the event is handled. This suppresses the blocking
      -- E211 (file no longer available) prompt and avoids errors in bufferline.
      vim.v.fcs_choice = ""
      if not deleted_buffers_notified[bufnr] then
        deleted_buffers_notified[bufnr] = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.notify(
              string.format("File '%s' was deleted on disk. Buffer kept in memory (use :w to recreate or <leader>w to close).", fname),
              vim.log.levels.WARN,
              { title = "File Deleted on Disk" }
            )
          end
        end)
      end
    elseif vim.v.fcs_reason == "changed" then
      vim.v.fcs_choice = "reload"
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.notify(
            string.format("File '%s' changed on disk. Automatically reloaded.", fname),
            vim.log.levels.INFO,
            { title = "File Reloaded" }
          )
        end
      end)
    elseif vim.v.fcs_reason == "conflict" then
      vim.v.fcs_choice = "ask"
    elseif vim.v.fcs_reason == "time" or vim.v.fcs_reason == "mode" then
      vim.v.fcs_choice = "reload"
    end
  end,
})

-- Reset the notified state when the file is written or the buffer is removed
vim.api.nvim_create_autocmd({ "BufWritePost", "BufWipeout", "BufDelete" }, {
  group = external_file_group,
  pattern = "*",
  callback = function(args)
    deleted_buffers_notified[args.buf] = nil
  end,
})

-- Run checktime on focus, buffer switch, and idle so external changes are noticed promptly
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = external_file_group,
  pattern = "*",
  callback = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "c" then return end
    if is_ignored_buffer() then return end
    if vim.api.nvim_buf_get_name(0) ~= "" then
      vim.cmd("checktime")
    end
  end,
})

-- =========================================================================
-- JUPYTEXT: .ipynb notebooks are edited as py:percent scripts
-- =========================================================================
local jupytext_group = vim.api.nvim_create_augroup("JupytextSync", { clear = true })

local function get_jupytext_cmd(sub_args)
  local local_bin = vim.fn.expand("~/.local/bin/jupytext")
  local cmd = {}
  if vim.fn.executable("jupytext") == 1 then
    table.insert(cmd, "jupytext")
  elseif vim.fn.executable(local_bin) == 1 then
    table.insert(cmd, local_bin)
  elseif vim.fn.executable("uvx") == 1 then
    table.insert(cmd, "uvx")
    table.insert(cmd, "jupytext")
  else
    table.insert(cmd, local_bin)
  end
  for _, arg in ipairs(sub_args) do
    table.insert(cmd, arg)
  end
  return cmd
end

-- Synchronous runner with stdout/stderr kept separate (stderr warnings must not leak into buffer content)
local function run_sync(cmd, stdin)
  local ok, res = pcall(function() return vim.system(cmd, { text = true, stdin = stdin }):wait() end)
  if not ok then return 1, "", tostring(res) end
  return res.code, res.stdout or "", res.stderr or ""
end

local function get_nbconvert_cmd(file)
  local local_bin = vim.fn.expand("~/.local/bin/jupyter")
  if vim.fn.executable("jupyter") == 1 then
    return { "jupyter", "nbconvert", "--to", "notebook", "--nbformat", "4", "--inplace", file }
  elseif vim.fn.executable(local_bin) == 1 then
    return { local_bin, "nbconvert", "--to", "notebook", "--nbformat", "4", "--inplace", file }
  elseif vim.fn.executable("jupyter-nbconvert") == 1 then
    return { "jupyter-nbconvert", "--to", "notebook", "--nbformat", "4", "--inplace", file }
  elseif vim.fn.executable("uvx") == 1 then
    return { "uvx", "--from", "nbconvert", "jupyter-nbconvert", "--to", "notebook", "--nbformat", "4", "--inplace", file }
  else
    return { "jupyter", "nbconvert", "--to", "notebook", "--nbformat", "4", "--inplace", file }
  end
end

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
  group = jupytext_group,
  pattern = "*.ipynb",
  callback = function(args)
    local file = args.file
    local cmd = get_jupytext_cmd({ "--to", "py:percent", "--output", "-", file })
    local code, out, err = run_sync(cmd)
    if code ~= 0 or out == "" then
      local fname = vim.fn.fnamemodify(file, ":t")
      vim.notify("Jupytext failed to convert " .. fname .. ":\n" .. (err ~= "" and err or "Empty output"), vim.log.levels.WARN)

      vim.schedule(function()
        local nb_cmd_display = 'jupyter nbconvert --to notebook --nbformat 4 --inplace "' .. fname .. '"'
        local options = {
          "Run: " .. nb_cmd_display,
          "Cancel"
        }

        vim.ui.select(options, {
          prompt = "[Jupytext Error] Format version incompatible.\nPress ENTER to run nbconvert, ESC to cancel:",
        }, function(choice, idx)
          if idx == 1 then
            local conv_cmd = get_nbconvert_cmd(file)
            vim.notify("Upgrading notebook format for " .. fname .. "...", vim.log.levels.INFO)
            local conv_code, conv_out, conv_err = run_sync(conv_cmd)
            if conv_code == 0 then
              vim.notify("Successfully upgraded " .. fname .. " to nbformat 4! Reloading...", vim.log.levels.INFO)
              local retry_cmd = get_jupytext_cmd({ "--to", "py:percent", "--output", "-", file })
              local retry_code, retry_out, retry_err = run_sync(retry_cmd)
              if retry_code == 0 and retry_out ~= "" then
                local lines = vim.split(retry_out, "\n", { trimempty = false })
                if vim.api.nvim_buf_is_valid(args.buf) then
                  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
                  vim.bo[args.buf].filetype = "python"
                  vim.bo[args.buf].modified = false
                end
              else
                vim.notify("Jupytext conversion failed after upgrade: " .. retry_err, vim.log.levels.ERROR)
              end
            else
              vim.notify("nbconvert failed:\n" .. conv_err .. conv_out, vim.log.levels.ERROR)
            end
          else
            vim.notify("Notebook format upgrade cancelled.", vim.log.levels.WARN)
          end
        end)
      end)
      return
    end

    local raw_lines = vim.split(out, "\n", { trimempty = false })
    local lines = {}
    local in_frontmatter = false
    for i, line in ipairs(raw_lines) do
      if i == 1 and line == "# ---" then
        in_frontmatter = true
      elseif in_frontmatter and line == "# ---" then
        in_frontmatter = false
      elseif not in_frontmatter then
        table.insert(lines, line)
      end
    end
    while #lines > 0 and lines[1] == "" do
      table.remove(lines, 1)
    end

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
    vim.bo[args.buf].filetype = "python"
    vim.bo[args.buf].modified = false
  end,
})

vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
  group = jupytext_group,
  pattern = "*.ipynb",
  callback = function(args)
    local file = args.file
    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    local cmd = get_jupytext_cmd({ "--from", "py:percent", "--to", "ipynb", "--output", file, "-" })
    local code, _, err = run_sync(cmd, content)
    if code ~= 0 then
      vim.notify("Jupytext failed to save " .. file .. ": " .. err, vim.log.levels.ERROR)
      return
    end
    vim.bo[args.buf].modified = false
  end,
})

-- =========================================================================
-- 5. COMMANDS AND KEYMAPS
-- =========================================================================

-- :ClearProjects: wipe the legacy project.nvim history file (if one remains)
vim.api.nvim_create_user_command("ClearProjects", function()
  local history_file = vim.fn.stdpath("data") .. "/project_nvim/project_history"
  os.remove(history_file)
  print("Project history cleared. (Restart Neovim to reflect changes)")
end, { desc = "Wipe the recent projects list" })

-- :AsyncDelete [path]: delete a file or folder in the background
vim.api.nvim_create_user_command("AsyncDelete", function(opts)
  local path = (opts.args ~= "") and vim.fn.expand(opts.args) or vim.api.nvim_buf_get_name(0)
  if not path or path == "" then
    vim.notify("No file or path specified to delete", vim.log.levels.WARN, { title = "Async Delete" })
    return
  end
  local name = vim.fn.fnamemodify(path, ":t")
  local is_dir = vim.fn.isdirectory(path) == 1
  local prompt_msg = string.format("Delete %s '%s' in background? [y/N]: ", is_dir and "folder" or "file", name)
  vim.ui.input({ prompt = prompt_msg }, function(choice)
    if choice and (choice:lower() == "y" or choice:lower() == "yes") then
      if _G.Async_Delete_Path then
        _G.Async_Delete_Path(path, function()
          local status_tree, tree_api = pcall(require, "nvim-tree.api")
          if status_tree then pcall(tree_api.tree.reload) end
        end)
      end
    end
  end)
end, { nargs = "?", complete = "file", desc = "Delete file or directory asynchronously in background" })

-- :CleanDeletedBuffers: close unmodified buffers whose file no longer exists on disk
vim.api.nvim_create_user_command("CleanDeletedBuffers", function()
  local closed = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
      local name = vim.api.nvim_buf_get_name(bufnr)
      local buftype = vim.bo[bufnr].buftype
      if buftype == "" and name ~= "" and vim.fn.filereadable(name) == 0 and not vim.bo[bufnr].modified then
        if _G.Safe_Delete_Buffer then
          _G.Safe_Delete_Buffer(bufnr, true)
        else
          pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end
        closed = closed + 1
      end
    end
  end
  if closed > 0 then
    vim.notify(string.format("Closed %d buffer(s) for deleted files.", closed), vim.log.levels.INFO, { title = "Clean Buffers" })
  else
    vim.notify("No deleted file buffers found.", vim.log.levels.INFO, { title = "Clean Buffers" })
  end
end, { desc = "Close all unmodified buffers whose underlying file was deleted from disk" })

-- Search
vim.keymap.set('n', '/', '/\\V', { noremap = true, desc = "Literal Search Forward" })
vim.keymap.set('v', '/', '/\\V', { noremap = true, desc = "Literal Search Forward" })
vim.keymap.set('n', '?', '?\\V', { noremap = true, desc = "Literal Search Backward" })
vim.keymap.set('v', '?', '?\\V', { noremap = true, desc = "Literal Search Backward" })

-- fzf-lua File Finders & Grep
vim.keymap.set('n', '<C-f>', function() require('fzf-lua').blines() end, { noremap = true, silent = true, desc = "Fuzzy Find in File (fzf-lua)" })
vim.keymap.set('n', '<leader>f', function() if _G.Ensure_Code_Window then _G.Ensure_Code_Window() end; require('fzf-lua').files() end, { noremap = true, silent = true, desc = "Find Files (fzf-lua)" })
vim.keymap.set('n', '<leader>F', function() if _G.Ensure_Code_Window then _G.Ensure_Code_Window() end; require('fzf-lua').live_grep() end, { noremap = true, silent = true, desc = "Find Text (fzf-lua)" })
vim.keymap.set('n', '<leader>d', function() _G.Fzf_Browse_Dirs() end, { noremap = true, silent = true, desc = "Browse Directories (Root)" })
vim.keymap.set('n', '<leader>fd', function() _G.Fzf_Browse_Dirs() end, { noremap = true, silent = true, desc = "Browse Directories (Root)" })
vim.keymap.set('n', '<leader>fb', function() _G.Fzf_Browse_Dirs() end, { noremap = true, silent = true, desc = "Browse Directories (Root)" })

-- =========================================================================
-- DEBUGGING KEYMAPS (DAP / Delve)
-- =========================================================================
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, { noremap = true, silent = true, desc = "Debug: Start / Continue" })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { noremap = true, silent = true, desc = "Debug: Toggle Breakpoint" })
vim.keymap.set('n', '<leader>dB', function()
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
    if condition and condition ~= "" then
      require('dap').set_breakpoint(condition)
    end
  end)
end, { noremap = true, silent = true, desc = "Debug: Conditional Breakpoint" })
vim.keymap.set('n', '<leader>dn', function() require('dap').step_over() end, { noremap = true, silent = true, desc = "Debug: Step Over (Next)" })
vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end, { noremap = true, silent = true, desc = "Debug: Step Into" })
vim.keymap.set('n', '<leader>do', function() require('dap').step_out() end, { noremap = true, silent = true, desc = "Debug: Step Out" })
vim.keymap.set('n', '<leader>dt', function()
  local ft = vim.bo.filetype
  if ft ~= "go" then
    vim.notify("Not a Go buffer", vim.log.levels.WARN)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local file_dir = vim.fs.dirname(file_path)
  local root = vim.fs.root(file_dir, { "go.mod", "go.work", ".git" }) or file_dir
  local rel_dir = "."
  if file_dir ~= root and file_dir:sub(1, #root) == root then
    rel_dir = "./" .. file_dir:sub(#root + 2):gsub("\\", "/")
  end
  require("dap") -- loads nvim-dap's config, which sets up dap-go
  local dap_go = require("dap-go")
  local ok = dap_go.debug_test({
    program = rel_dir,
    cwd = root,
  })
  if not ok then
    require("dap").run({
      type = "go",
      name = "Debug Test (Package)",
      request = "launch",
      mode = "test",
      program = rel_dir,
      cwd = root,
      outputMode = "remote",
    })
  end
end, { noremap = true, silent = true, desc = "Debug: Go Test Under Cursor" })
vim.keymap.set('n', '<leader>dT', function() require('dap'); require('dap-go').debug_last_test() end, { noremap = true, silent = true, desc = "Debug: Last Go Test" })
vim.keymap.set('n', '<leader>dq', function()
  require('dap').terminate()
  require('dapui').close()
end, { noremap = true, silent = true, desc = "Debug: Terminate & Close UI" })
vim.keymap.set('n', '<leader>du', function() require('dap'); require('dapui').toggle() end, { noremap = true, silent = true, desc = "Debug: Toggle DAP UI" })
vim.keymap.set('n', '<leader>dr', function() require('dap').repl.toggle() end, { noremap = true, silent = true, desc = "Debug: Toggle REPL" })
vim.keymap.set({ 'n', 'v' }, '<leader>de', function() require('dap'); require('dapui').eval() end, { noremap = true, silent = true, desc = "Debug: Evaluate Expression" })

-- =========================================================================
-- PROJECTS AND SESSIONS
-- =========================================================================
vim.keymap.set('n', '<leader>p', function() _G.Search_Sessions() end, { noremap = true, silent = true, desc = "Active Projects (Restore Tabs)" })
vim.keymap.set('n', '<leader>fp', function() _G.Open_Project_In_Tree() end, { noremap = true, silent = true, desc = "Find Recent Project Folders" })

-- Aerial code outline sidebar
vim.keymap.set("n", "<leader>a", function()
  -- If we're in a sidebar, switch to the code window first
  local ft = vim.bo.filetype
  if ft == "NvimTree" or ft == "aerial" or ft == "toggleterm" or ft == "trouble" then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local wft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" and wft ~= "NvimTree" and wft ~= "aerial" and wft ~= "toggleterm" and wft ~= "trouble" and wft ~= "alpha" then
        vim.api.nvim_set_current_win(win)
        break
      end
    end
  end

  local aerial = require("aerial")
  if aerial.is_open() then
    aerial.close()
  else
    aerial.open({ focus = false })
    if _G.Fix_Sidebar_Widths then vim.schedule(_G.Fix_Sidebar_Widths) end
  end
end, { noremap = true, silent = true, desc = "Toggle Code Structure Sidebar" })

-- =========================================================================
-- HOME (RETURN TO DASHBOARD)
-- =========================================================================
vim.keymap.set('n', '<leader>h', function()
  if vim.bo.filetype == "alpha" then return end
  _G.Close_Project() -- Save session under the project's own root, then close everything
  vim.cmd("Alpha") -- Open Dashboard
end, { noremap = true, silent = true, desc = "Save & Return to Dashboard" })

-- Cycle focus between NvimTree, the code window, and Aerial (forward and reverse)
local function cycle_panel_focus(reverse)
  local current_ft = vim.bo.filetype

  -- Helper: find the first normal (non-sidebar) code window
  local function find_code_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" and ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "alpha" then
        return win
      end
    end
    return nil
  end

  -- Helper: find the aerial window (if open)
  local function find_aerial_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" and ft == "aerial" then
        return win
      end
    end
    return nil
  end

  local aerial_win = find_aerial_win()
  local code_win = find_code_win()

  if reverse then
    -- Reverse direction: NvimTree -> Aerial -> Code -> NvimTree
    if current_ft == "NvimTree" then
      if aerial_win then
        vim.api.nvim_set_current_win(aerial_win)
      elseif code_win then
        vim.api.nvim_set_current_win(code_win)
      end
    elseif current_ft == "aerial" then
      if code_win then
        vim.api.nvim_set_current_win(code_win)
      else
        vim.cmd("wincmd p")
      end
    else
      vim.cmd("NvimTreeFocus")
    end
  else
    -- Forward direction: NvimTree -> Code -> Aerial -> NvimTree
    if current_ft == "NvimTree" then
      if code_win then
        vim.api.nvim_set_current_win(code_win)
      else
        vim.cmd("wincmd p")
      end
    elseif current_ft == "aerial" then
      vim.cmd("NvimTreeFocus")
    else
      if aerial_win then
        vim.api.nvim_set_current_win(aerial_win)
      else
        vim.cmd("NvimTreeFocus")
      end
    end
  end
end

vim.keymap.set({'n', 'i', 'v'}, '<C-M-e>', function() cycle_panel_focus(false) end, { noremap = true, silent = true, desc = "Cycle Focus Forward: File -> Structure -> Tree" })
vim.keymap.set({'n', 'i', 'v'}, '<C-M-S-e>', function() cycle_panel_focus(true) end, { noremap = true, silent = true, desc = "Cycle Focus Reverse: File -> Tree -> Structure" })
vim.keymap.set({'n', 'i', 'v'}, '<C-A-S-e>', function() cycle_panel_focus(true) end, { noremap = true, silent = true, desc = "Cycle Focus Reverse: File -> Tree -> Structure" })

-- Alt+e / Alt+Shift+e: fallbacks for terminals that don't pass Ctrl+Alt+Shift
vim.keymap.set({'n', 'i', 'v'}, '<M-e>', function() cycle_panel_focus(false) end, { noremap = true, silent = true, desc = "Cycle Focus Forward: File -> Structure -> Tree" })
vim.keymap.set({'n', 'i', 'v'}, '<M-S-e>', function() cycle_panel_focus(true) end, { noremap = true, silent = true, desc = "Cycle Focus Reverse: File -> Tree -> Structure" })

-- Split panes: code windows, as opposed to sidebars, terminals, and floats
local function is_code_win(win)
  if vim.api.nvim_win_get_config(win).relative ~= "" then return false end
  local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
  return ft ~= "NvimTree" and ft ~= "aerial" and ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "alpha"
end

-- Is the buffer showing in some other pane of the current tab?
local function shown_in_other_pane(bufnr)
  local cur = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= cur and vim.api.nvim_win_get_buf(win) == bufnr and is_code_win(win) then return win end
  end
end

-- Show a buffer: jump to the pane already showing it, otherwise open it in the focused code pane
function _G.Show_Buffer(bufnr)
  local win = shown_in_other_pane(bufnr)
  if win then return vim.api.nvim_set_current_win(win) end
  if not is_code_win(0) and _G.Ensure_Code_Window then _G.Ensure_Code_Window() end
  vim.api.nvim_set_current_buf(bufnr)
end

-- Buffer Navigation: cycle files in the focused pane in tab-bar order, skipping files already shown in
-- another split (so both panes never end up showing the same file)
local function cycle_buffers(step)
  local cur = vim.api.nvim_get_current_buf()
  local function index_of(list)
    for i, id in ipairs(list) do
      if id == cur then return i end
    end
  end

  local ok, bufferline = pcall(require, "bufferline")
  local order = ok and vim.tbl_map(function(e) return e.id end, bufferline.get_elements().elements) or {}
  local idx = index_of(order)
  if not idx then -- Tab bar not drawn yet or current buffer not in it: fall back to buffer-number order
    order = vim.tbl_map(function(b) return b.bufnr end, vim.fn.getbufinfo({ buflisted = 1 }))
    idx = index_of(order)
  end
  if not idx then
    pcall(vim.cmd, step > 0 and "bnext" or "bprevious")
    return
  end

  for i = 1, #order - 1 do
    local id = order[(idx - 1 + step * i) % #order + 1]
    if not shown_in_other_pane(id) then
      vim.api.nvim_set_current_buf(id)
      return
    end
  end
end

vim.keymap.set('n', '<Tab>', function() cycle_buffers(1) end, { noremap = true, silent = true, desc = "Next File Tab" })
vim.keymap.set('n', '<S-Tab>', function() cycle_buffers(-1) end, { noremap = true, silent = true, desc = "Previous File Tab" })

-- Window Split Navigation (Ctrl+h/j/k/l moves between panes and sidebars)
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true, desc = "Focus Pane Left" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true, desc = "Focus Pane Below" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true, desc = "Focus Pane Above" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true, desc = "Focus Pane Right" })

-- Only the focused code pane shows the cursorline, so it's obvious which split has focus
-- (sidebars keep theirs: it marks the selected node/symbol)
local function set_pane_cursorline(on)
  return function()
    if vim.bo.buftype ~= "" or not is_code_win(0) then return end
    vim.opt_local.cursorline = on
  end
end
local pane_focus_group = vim.api.nvim_create_augroup("PaneFocusCursorline", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, { group = pane_focus_group, callback = set_pane_cursorline(true) })
vim.api.nvim_create_autocmd("WinLeave", { group = pane_focus_group, callback = set_pane_cursorline(false) })

-- Smart Close
local function get_normal_window_count()
  local count = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
      if ft ~= "NvimTree" and ft ~= "toggleterm" and ft ~= "trouble" and ft ~= "aerial" and ft ~= "alpha" then
        count = count + 1
      end
    end
  end
  return count
end

-- Close a file like an editor tab: ask about unsaved changes, close the split panes showing it
-- (never the last code pane, which switches to another file instead), then drop it from the tab bar
function _G.Close_File(bufnr)
  bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  if vim.bo[bufnr].modified then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    local choice = vim.fn.confirm(("Save changes to '%s'?"):format(name ~= "" and name or "[No Name]"), "&Save\n&Discard\n&Cancel", 1, "Question")
    if choice == 1 then
      pcall(vim.api.nvim_buf_call, bufnr, function() vim.cmd("write") end)
      if vim.bo[bufnr].modified then return end -- Write failed (e.g. no file name): keep the file open
    elseif choice ~= 2 then
      return
    end
  end

  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    local tab_panes = vim.tbl_filter(is_code_win, vim.api.nvim_tabpage_list_wins(vim.api.nvim_win_get_tabpage(win)))
    if is_code_win(win) and #tab_panes > 1 then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end

  if _G.Safe_Delete_Buffer then
    _G.Safe_Delete_Buffer(bufnr, true)
  else
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end
end

vim.keymap.set('n', '<leader>w', function()
  if vim.bo.filetype == "NvimTree" or vim.bo.filetype == "aerial" or vim.bo.filetype == "alpha" then return end
  -- Help, quickfix, and other special windows: just close the pane
  if vim.bo.buftype ~= "" and get_normal_window_count() > 1 then
    vim.cmd("close")
    return
  end
  _G.Close_File(0)
end, { noremap = true, silent = true, desc = "Close File (and its Split)" })

-- General Core Bindings
vim.keymap.set('n', '<leader>q', function()
  local is_dashboard = vim.bo.filetype == "alpha"
  if not is_dashboard then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_get_option_value("filetype", { buf = buf }) == "alpha" then
          is_dashboard = true
          break
        end
      end
    end
  end

  if is_dashboard then
    vim.cmd("qa")
  else
    vim.notify("Quitting Neovim is only allowed from the dashboard. Use <leader>h to return to dashboard.", vim.log.levels.WARN, { title = "Quit NVIM" })
  end
end, { noremap = true, silent = true, desc = "Quit NVIM (Dashboard Only)" })
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<cmd>w<CR>', { noremap = true, silent = true })
-- Undo / redo (Ctrl+z is not used to suspend Neovim)
vim.keymap.set('n', '<C-z>', 'u', { noremap = true, silent = true, desc = "Undo" })
vim.keymap.set('i', '<C-z>', '<C-g>u<C-o>u', { noremap = true, silent = true, desc = "Undo (Insert)" })
vim.keymap.set({ 'v', 'x', 's' }, '<C-z>', '<Esc>u', { noremap = true, silent = true, desc = "Undo" })
vim.keymap.set({ 'c', 't' }, '<C-z>', '<Nop>', { noremap = true, silent = true, desc = "Disabled Ctrl-Z suspension" })

vim.keymap.set('n', '<C-y>', '<C-r>', { noremap = true, silent = true, desc = "Redo" })
vim.keymap.set('i', '<C-y>', '<C-o><C-r>', { noremap = true, silent = true, desc = "Redo (Insert)" })
vim.keymap.set({ 'v', 'x', 's' }, '<C-y>', '<Esc><C-r>', { noremap = true, silent = true, desc = "Redo" })
-- Smart escape: stops any active snippet, clears search highlights, and returns to Normal mode
local function smart_escape()
  if vim.snippet and vim.snippet.active() then
    pcall(vim.snippet.stop)
  end
  vim.cmd("nohlsearch")
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "n" then
    vim.cmd("stopinsert")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

-- Stop snippet sessions on leaving Insert/Select mode so placeholders can't trap the cursor
vim.api.nvim_create_autocmd("ModeChanged", {
  group = vim.api.nvim_create_augroup("SnippetAutoStop", { clear = true }),
  pattern = { "i:n", "s:n", "i:v", "s:v" },
  callback = function()
    if vim.snippet and vim.snippet.active() then
      pcall(vim.snippet.stop)
    end
  end,
})

vim.keymap.set('n', '<Esc>', smart_escape, { noremap = true, silent = true, desc = "Escape / Clear Search / Stop Snippet" })
vim.keymap.set('c', '<M-j>', smart_escape, { noremap = true, silent = true, desc = "Escape (Cmdline)" })

-- Alt+u: escape
vim.keymap.set({ 'i', 'n', 'v', 'x', 's', 'c' }, '<M-u>', smart_escape, { noremap = true, silent = true, desc = "Escape / Clear Search / Stop Snippet" })
vim.keymap.set({ 'i', 'n', 'v', 'x', 's', 'c' }, '<M-U>', smart_escape, { noremap = true, silent = true, desc = "Escape / Clear Search / Stop Snippet" })
vim.keymap.set({ 'i', 'n', 'v', 'x', 's', 'c' }, '<M-S-u>', smart_escape, { noremap = true, silent = true, desc = "Escape / Clear Search / Stop Snippet" })

-- Alt+b: backspace
vim.keymap.set({ 'i', 'c' }, '<M-b>', '<BS>', { noremap = true, silent = true, desc = "Backspace" })

-- Alt+o: run one Normal-mode command from Insert mode
vim.keymap.set('i', '<M-o>', '<C-o>', { noremap = true, silent = true, desc = "Execute single Normal command from Insert" })
vim.keymap.set('i', '<M-O>', '<C-o>', { noremap = true, silent = true, desc = "Execute single Normal command from Insert" })
vim.keymap.set('i', '<M-S-o>', '<C-o>', { noremap = true, silent = true, desc = "Execute single Normal command from Insert" })

-- Alt+h/j/k/l: directional movement
-- Insert mode: character/line stepping
vim.keymap.set('i', '<M-h>', '<Left>',  { noremap = true, silent = true, desc = "Move Left (Insert)" })
vim.keymap.set('i', '<M-j>', '<Down>',  { noremap = true, silent = true, desc = "Move Down (Insert)" })
vim.keymap.set('i', '<M-k>', '<Up>',    { noremap = true, silent = true, desc = "Move Up (Insert)" })
vim.keymap.set('i', '<M-l>', '<Right>', { noremap = true, silent = true, desc = "Move Right (Insert)" })

-- Normal mode: directional movement
vim.keymap.set('n', '<M-h>', 'h', { noremap = true, silent = true, desc = "Move Left (Normal)" })
vim.keymap.set('n', '<M-j>', 'j', { noremap = true, silent = true, desc = "Move Down (Normal)" })
vim.keymap.set('n', '<M-k>', 'k', { noremap = true, silent = true, desc = "Move Up (Normal)" })
vim.keymap.set('n', '<M-l>', 'l', { noremap = true, silent = true, desc = "Move Right (Normal)" })

-- Visual / Select mode: cancel the selection and move, returning to Insert if it began there
local function cancel_visual_and_move(dir)
  local from_insert = _G._selection_from_insert
  _G._selection_from_insert = false

  local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false)

  if from_insert then
    if dir == 'l' then
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if col >= #line - 1 then
        vim.cmd('startinsert!')
      else
        pcall(vim.cmd, 'normal! l')
        vim.cmd('startinsert')
      end
    else
      pcall(vim.cmd, 'normal! ' .. dir)
      vim.cmd('startinsert')
    end
  else
    pcall(vim.cmd, 'normal! ' .. dir)
  end
end

for _, key in ipairs({ 'h', 'j', 'k', 'l' }) do
  local dir_names = { h = "Left", j = "Down", k = "Up", l = "Right" }
  vim.keymap.set({ 'v', 'x', 's' }, '<M-' .. key .. '>', function()
    cancel_visual_and_move(key)
  end, { noremap = true, silent = true, desc = "Cancel Selection & Move " .. dir_names[key] })
end

-- Alt+Shift+h / Alt+Shift+l: jump to line start (first non-blank, then column 0) or line end
local function jump_to_line_start_insert()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local first_non_blank = line:find("%S")
  local target_col = first_non_blank and (first_non_blank - 1) or 0
  -- Already at or before the first non-blank character: go to column 0 instead
  if col == target_col then
    vim.api.nvim_win_set_cursor(0, { row, 0 })
  else
    vim.api.nvim_win_set_cursor(0, { row, target_col })
  end
end

local function jump_to_line_end_insert()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_win_set_cursor(0, { row, #line })
end

-- Insert mode jumps (stays in insert mode)
vim.keymap.set('i', '<M-S-h>', jump_to_line_start_insert, { noremap = true, silent = true, desc = "Go to First Character / Line Start (Insert)" })
vim.keymap.set('i', '<M-H>',   jump_to_line_start_insert, { noremap = true, silent = true, desc = "Go to First Character / Line Start (Insert)" })
vim.keymap.set('i', '<M-S-l>', jump_to_line_end_insert,   { noremap = true, silent = true, desc = "Go to Line End (Insert)" })
vim.keymap.set('i', '<M-L>',   jump_to_line_end_insert,   { noremap = true, silent = true, desc = "Go to Line End (Insert)" })

-- Normal mode jumps
vim.keymap.set('n', '<M-S-h>', '^', { noremap = true, silent = true, desc = "Go to First Non-Blank Character" })
vim.keymap.set('n', '<M-H>',   '^', { noremap = true, silent = true, desc = "Go to First Non-Blank Character" })
vim.keymap.set('n', '<M-S-l>', '$', { noremap = true, silent = true, desc = "Go to Line End" })
vim.keymap.set('n', '<M-L>',   '$', { noremap = true, silent = true, desc = "Go to Line End" })

-- Visual / Selection mode jumps
vim.keymap.set({ 'v', 'x' }, '<M-S-h>', '^', { noremap = true, silent = true, desc = "Extend Selection to First Non-Blank Character" })
vim.keymap.set({ 'v', 'x' }, '<M-H>',   '^', { noremap = true, silent = true, desc = "Extend Selection to First Non-Blank Character" })
vim.keymap.set({ 'v', 'x' }, '<M-S-l>', '$', { noremap = true, silent = true, desc = "Extend Selection to Line End" })
vim.keymap.set({ 'v', 'x' }, '<M-L>',   '$', { noremap = true, silent = true, desc = "Extend Selection to Line End" })

-- Ctrl+h / Ctrl+l fallback in Insert mode
vim.keymap.set('i', '<C-h>', '<Home>', { noremap = true, silent = true, desc = "Go to Line Start (Insert)" })
vim.keymap.set('i', '<C-l>', '<End>',  { noremap = true, silent = true, desc = "Go to Line End (Insert)" })

-- Word navigation (Alt+w / Alt+Shift+w)
-- Forward word (Alt + w)
vim.keymap.set('i', '<M-w>', '<C-o>w', { noremap = true, silent = true, desc = "Move Forward Word (Insert)" })
vim.keymap.set({ 'n', 'v', 'x' }, '<M-w>', 'w', { noremap = true, silent = true, desc = "Move Forward Word" })
vim.keymap.set('c', '<M-w>', '<S-Right>', { noremap = true, silent = true, desc = "Move Forward Word (Cmdline)" })

-- Backward word (Alt + Shift + w / Alt + W)
vim.keymap.set('i', '<M-S-w>', '<C-o>b', { noremap = true, silent = true, desc = "Move Backward Word (Insert)" })
vim.keymap.set('i', '<M-W>',   '<C-o>b', { noremap = true, silent = true, desc = "Move Backward Word (Insert)" })
vim.keymap.set({ 'n', 'v', 'x' }, '<M-S-w>', 'b', { noremap = true, silent = true, desc = "Move Backward Word" })
vim.keymap.set({ 'n', 'v', 'x' }, '<M-W>',   'b', { noremap = true, silent = true, desc = "Move Backward Word" })
vim.keymap.set('c', '<M-S-w>', '<S-Left>', { noremap = true, silent = true, desc = "Move Backward Word (Cmdline)" })
vim.keymap.set('c', '<M-W>',   '<S-Left>', { noremap = true, silent = true, desc = "Move Backward Word (Cmdline)" })

-- Open the current file in the OS default viewer
vim.keymap.set('n', '<leader>o', function()
  local path = ""
  if vim.bo.filetype == "NvimTree" then
    local status_ok, api = pcall(require, "nvim-tree.api")
    if status_ok then
      local node = api.tree.get_node_under_cursor()
      if node then path = node.absolute_path; if node.type == "file" then path = vim.fn.fnamemodify(path, ":h") end end
    end
    if path == "" then path = vim.fn.getcwd() end
  else path = vim.fn.expand('%:p') end
  if path == "" then return end
  if vim.fn.has('mac') == 1 then vim.fn.jobstart({ 'open', path }, { detach = true })
  elseif vim.fn.has('unix') == 1 then vim.fn.jobstart({ 'xdg-open', path }, { detach = true })
  elseif vim.fn.has('win32') == 1 then vim.fn.jobstart({ 'cmd', '/c', 'start', '""', path }, { detach = true }) end
end, { noremap = true, silent = true, desc = "Open in OS Explorer" })

-- Binary file handling: known binary extensions, plus unknown binaries detected by a NUL-byte sniff
local function open_external(path)
  if vim.fn.has('mac') == 1 then vim.fn.jobstart({ 'open', path }, { detach = true })
  elseif vim.fn.has('unix') == 1 then vim.fn.jobstart({ 'xdg-open', path }, { detach = true })
  elseif vim.fn.has('win32') == 1 then vim.fn.jobstart({ 'cmd', '/c', 'start', '""', path }, { detach = true }) end
end

-- Binary formats an OS viewer can open
local external_exts = {
  "pdf", "mp4", "mkv", "avi", "mov", "webm", "mp3", "flac", "wav",
  "zip", "tar", "gz", "bz2", "xz", "zst", "7z", "rar", "iso", "whl",
  "docx", "xlsx", "pptx",
}
-- Tabular/data binaries: show a text preview instead
local data_exts = { "parquet", "feather", "arrow", "orc", "avro", "npy", "npz", "pkl", "pickle", "h5", "hdf5", "sqlite", "db" }
-- Opaque binaries: refuse to load
local opaque_exts = { "pt", "pth", "onnx", "safetensors", "so", "o", "a", "exe", "dll", "bin", "class", "pyc" }

local function ext_set(list) local s = {} for _, e in ipairs(list) do s[e] = true end return s end
local ext_external, ext_data, ext_opaque = ext_set(external_exts), ext_set(data_exts), ext_set(opaque_exts)

local function is_binary_content(path)
  local f = io.open(path, "rb")
  if not f then return false end
  local chunk = f:read(8192) or ""
  f:close()
  return chunk:find("\0", 1, true) ~= nil
end

-- Return preview lines for a data file, or nil if no suitable tool is installed
local function preview_data_file(path)
  local ext = path:match("%.([^./]+)$"):lower()
  local py_by_ext = {
    parquet = "import pyarrow.parquet as pq,sys; f=pq.ParquetFile(sys.argv[1]); print(f.schema_arrow); print('rows:', f.metadata.num_rows, ' row_groups:', f.num_row_groups); print(); print(f.read_row_group(0).slice(0,100).to_pandas().to_string())",
    feather = "import pyarrow.feather as ft,sys; t=ft.read_table(sys.argv[1]); print(t.schema); print('rows:', t.num_rows); print(t.slice(0,100).to_pandas().to_string())",
    npy = "import numpy as np,sys; a=np.load(sys.argv[1], mmap_mode='r'); print(a.dtype, a.shape); print(a[:100])",
  }
  local cmd
  if ext == "parquet" and vim.fn.executable("duckdb") == 1 then
    local q = ("DESCRIBE SELECT * FROM '%s'; SELECT count(*) AS total_rows FROM '%s'; SELECT * FROM '%s' LIMIT 100;"):format(path, path, path)
    cmd = { "duckdb", "-c", q }
  elseif ext == "parquet" and vim.fn.executable("pqrs") == 1 then
    cmd = { "pqrs", "head", "--records", "100", path }
  elseif ext == "parquet" and vim.fn.executable("parquet-tools") == 1 then
    cmd = { "parquet-tools", "show", "--n", "100", path }
  elseif py_by_ext[ext] and vim.fn.executable("python3") == 1 then
    cmd = { "python3", "-c", py_by_ext[ext], path }
  elseif ext == "sqlite" or ext == "db" then
    if vim.fn.executable("sqlite3") == 1 then cmd = { "sqlite3", path, ".schema" } end
  end
  if not cmd then return nil end
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 or out == "" then return nil end
  return vim.split(out, "\n", { trimempty = false })
end

local function show_preview(buf, path, lines)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_name(buf, "[preview] " .. vim.fn.fnamemodify(path, ":t"))
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    vim.wo.wrap = false
  end)
end

local function reject_binary(buf, path, msg)
  vim.notify(msg .. ": " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.WARN)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end)
end

local binary_group = vim.api.nvim_create_augroup("BinaryGuard", { clear = true })

-- Known extensions: BufReadCmd replaces the reader, so the file is never read into memory
local function known_binary_reader(args)
  local path = vim.fn.fnamemodify(args.match, ":p")
  local ext = (path:match("%.([^./]+)$") or ""):lower()
  if ext_external[ext] then
    open_external(path)
    reject_binary(args.buf, path, "Opened externally")
  elseif ext_data[ext] then
    local lines = preview_data_file(path)
    if lines then show_preview(args.buf, path, lines)
    else reject_binary(args.buf, path, "Binary data file, no preview tool found (install duckdb or pyarrow)") end
  else
    reject_binary(args.buf, path, "Binary file not opened")
  end
end

local known_patterns = {}
for _, list in ipairs({ external_exts, data_exts, opaque_exts }) do
  for _, e in ipairs(list) do table.insert(known_patterns, "*." .. e) end
end
vim.api.nvim_create_autocmd("BufReadCmd", { group = binary_group, pattern = known_patterns, callback = known_binary_reader })

-- Unknown extensions: check the first 8 KB for NUL bytes; also applies the large-file guard to text files
local LARGE_FILE_BYTES = 2 * 1024 * 1024
vim.api.nvim_create_autocmd("BufReadPre", {
  group = binary_group,
  callback = function(args)
    local path = vim.fn.fnamemodify(args.match, ":p")
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.type ~= "file" then return end
    if is_binary_content(path) then
      return reject_binary(args.buf, path, "Binary file not opened")
    end
    if stat.size > LARGE_FILE_BYTES then
      vim.b[args.buf].large_file = true
      vim.opt_local.swapfile = false
      vim.opt_local.undolevels = -1
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.synmaxcol = 200
      vim.notify(("Large file (%.1f MB): syntax/treesitter/LSP disabled"):format(stat.size / 1048576), vim.log.levels.INFO)
    end
  end,
})

-- Runs after filetype detection so it can override plugin defaults
vim.api.nvim_create_autocmd("FileType", {
  group = binary_group,
  callback = function(args)
    if not vim.b[args.buf].large_file then return end
    vim.cmd("syntax clear")
    vim.opt_local.syntax = "off"
    pcall(vim.treesitter.stop, args.buf)
    vim.opt_local.wrap = false
    vim.opt_local.relativenumber = false
  end,
})

-- <leader>G: open the git remote in the browser
vim.keymap.set('n', '<leader>G', function()
  vim.system({ "git", "config", "--get", "remote.origin.url" }, { text = true }, function(res)
    local url = vim.trim(res.stdout or "")
    if res.code ~= 0 or url == "" then return end
    url = url:gsub("^git@([^:]+):", "https://%1/"):gsub("%.git$", "")
    vim.schedule(function() vim.ui.open(url) end)
  end)
end, { noremap = true, silent = true, desc = "Open Git Remote" })

-- Terminal buffers: no editor chrome, large scrollback, and mouse select-to-copy.
-- The global selectmode=mouse turns a drag into Select mode, which is useless in a terminal
-- buffer, so selectmode is cleared while a terminal buffer is focused and restored afterwards.
local term_group = vim.api.nvim_create_augroup("NativeTerminal", { clear = true })
local saved_selectmode
local function term_enter()
  if vim.bo.buftype ~= "terminal" then return end
  if not saved_selectmode then saved_selectmode = vim.o.selectmode end
  vim.o.selectmode = ""
end
local function term_leave()
  if saved_selectmode then
    vim.o.selectmode = saved_selectmode
    saved_selectmode = nil
  end
end
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_group,
  callback = function(args)
    local wo = vim.wo[vim.fn.bufwinid(args.buf)] or vim.wo
    wo.number = false
    wo.relativenumber = false
    wo.signcolumn = "no"
    wo.list = false
    wo.cursorline = false
    wo.scrolloff = 0
    vim.bo[args.buf].scrollback = 100000
    -- Copy-on-select: releasing the mouse after a drag yanks the selection to the system clipboard
    vim.keymap.set("v", "<LeftRelease>", '"+ygv', { buffer = args.buf, silent = true, desc = "Copy selection" })
    vim.keymap.set("v", "<RightMouse>", '"+y', { buffer = args.buf, silent = true, desc = "Copy selection" })
    vim.keymap.set("n", "<RightMouse>", '"+p', { buffer = args.buf, silent = true, desc = "Paste" })
    term_enter()
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TermEnter" }, { group = term_group, callback = term_enter })
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, { group = term_group, callback = term_leave })

-- Terminal mode: exit and split shortcuts
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>', { noremap = true, silent = true, desc = "Terminal (Horizontal)" })
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical size=40<CR>', { noremap = true, silent = true, desc = "Terminal (Vertical)" })

-- =========================================================================
-- SELECTION TRACKING AND VISUAL / SELECT MODE HANDLERS
-- =========================================================================
-- Records whether the current selection started from Insert mode
_G._selection_from_insert = false
local last_insert_exit = 0
local insert_selection_group = vim.api.nvim_create_augroup("InsertModeSelectionTracking", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
  group = insert_selection_group,
  pattern = "i:*",
  callback = function()
    last_insert_exit = vim.uv.hrtime()
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = insert_selection_group,
  pattern = "*:[vs\x16]*",
  callback = function()
    local diff_ms = (vim.uv.hrtime() - last_insert_exit) / 1e6
    if diff_ms < 150 then
      _G._selection_from_insert = true
    end
  end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = insert_selection_group,
  pattern = "[vs\x16]*:n",
  callback = function()
    vim.schedule(function()
      if vim.api.nvim_get_mode().mode == "n" then
        _G._selection_from_insert = false
      end
    end)
  end,
})

local function ensure_visual_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode:find("s") then
    local cg = vim.api.nvim_replace_termcodes("<C-g>", true, false, true)
    vim.api.nvim_feedkeys(cg, "x", false)
  end
end

local function visual_yank()
  local from_insert = _G._selection_from_insert
  _G._selection_from_insert = false
  ensure_visual_mode()
  local cur = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! y")
  if from_insert then
    pcall(vim.api.nvim_win_set_cursor, 0, cur)
    vim.cmd("startinsert")
  end
end

local function visual_cut()
  local from_insert = _G._selection_from_insert
  _G._selection_from_insert = false
  ensure_visual_mode()
  vim.cmd("normal! d")
  if from_insert then
    vim.cmd("startinsert")
  end
end

local function visual_delete_blackhole()
  local from_insert = _G._selection_from_insert
  _G._selection_from_insert = false
  ensure_visual_mode()
  vim.cmd('normal! "_d')
  if from_insert then
    vim.cmd("startinsert")
  end
end

local function visual_paste()
  local from_insert = _G._selection_from_insert
  _G._selection_from_insert = false
  ensure_visual_mode()
  vim.cmd('normal! "_dP')
  if from_insert then
    vim.cmd("startinsert")
  end
end

local function start_selection_from_insert(motion)
  _G._selection_from_insert = true
  vim.cmd("stopinsert")
  vim.cmd("normal! v" .. motion)
end

-- Visual / Select mode overrides
local modes = {'v', 'x', 's'}
for _, mode in ipairs(modes) do
  vim.keymap.set(mode, '<BS>', visual_delete_blackhole, { noremap = true, silent = true, desc = "Delete selection" })
  vim.keymap.set(mode, '<Del>', visual_delete_blackhole, { noremap = true, silent = true, desc = "Delete selection" })
  vim.keymap.set(mode, 'p', visual_paste, { noremap = true, silent = true, desc = "Paste over selection" })
  vim.keymap.set(mode, 'P', visual_paste, { noremap = true, silent = true, desc = "Paste over selection" })
end

-- Selection keys (Shift+H/J/K/L, Shift+W/B, Shift+Arrows)
-- Shift + H: Select word backward (left in line)
vim.keymap.set('n', 'H', 'vb', { noremap = true, silent = true, desc = "Select word backward" })
vim.keymap.set('n', '<S-h>', 'vb', { noremap = true, silent = true, desc = "Select word backward" })
vim.keymap.set({ 'v', 'x' }, 'H', 'b', { noremap = true, silent = true, desc = "Extend selection word backward" })
vim.keymap.set({ 'v', 'x' }, '<S-h>', 'b', { noremap = true, silent = true, desc = "Extend selection word backward" })

-- Shift + L: Select word forward (right in line)
vim.keymap.set('n', 'L', 'vw', { noremap = true, silent = true, desc = "Select word forward" })
vim.keymap.set('n', '<S-l>', 'vw', { noremap = true, silent = true, desc = "Select word forward" })
vim.keymap.set({ 'v', 'x' }, 'L', 'w', { noremap = true, silent = true, desc = "Extend selection word forward" })
vim.keymap.set({ 'v', 'x' }, '<S-l>', 'w', { noremap = true, silent = true, desc = "Extend selection word forward" })

-- Shift + J: Select multiple lines downward
vim.keymap.set('n', 'J', 'vj', { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set('n', '<S-j>', 'vj', { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set({ 'v', 'x' }, 'J', 'j', { noremap = true, silent = true, desc = "Extend selection downward" })
vim.keymap.set({ 'v', 'x' }, '<S-j>', 'j', { noremap = true, silent = true, desc = "Extend selection downward" })

-- Shift + K: Select multiple lines upward
vim.keymap.set('n', 'K', 'vk', { noremap = true, silent = true, desc = "Select line upward" })
vim.keymap.set('n', '<S-k>', 'vk', { noremap = true, silent = true, desc = "Select line upward" })
vim.keymap.set({ 'v', 'x' }, 'K', 'k', { noremap = true, silent = true, desc = "Extend selection upward" })
vim.keymap.set({ 'v', 'x' }, '<S-k>', 'k', { noremap = true, silent = true, desc = "Extend selection upward" })

-- Shift + W: Select forward WORD (enters Visual mode and extends selection)
vim.keymap.set('n', 'W', 'vW', { noremap = true, silent = true, desc = "Select forward WORD" })
vim.keymap.set('n', '<S-w>', 'vW', { noremap = true, silent = true, desc = "Select forward WORD" })
vim.keymap.set({ 'v', 'x' }, 'W', 'W', { noremap = true, silent = true, desc = "Extend selection forward WORD" })
vim.keymap.set({ 'v', 'x' }, '<S-w>', 'W', { noremap = true, silent = true, desc = "Extend selection forward WORD" })

-- Shift + B: Select backward WORD (enters Visual mode and extends selection)
vim.keymap.set('n', 'B', 'vB', { noremap = true, silent = true, desc = "Select backward WORD" })
vim.keymap.set('n', '<S-b>', 'vB', { noremap = true, silent = true, desc = "Select backward WORD" })
vim.keymap.set({ 'v', 'x' }, 'B', 'B', { noremap = true, silent = true, desc = "Extend selection backward WORD" })
vim.keymap.set({ 'v', 'x' }, '<S-b>', 'B', { noremap = true, silent = true, desc = "Extend selection backward WORD" })

-- Shift + Arrow Keys Selection
vim.keymap.set('n', '<S-Down>', 'vj', { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set('n', '<S-Up>', 'vk', { noremap = true, silent = true, desc = "Select line upward" })
vim.keymap.set('n', '<S-Left>', 'vb', { noremap = true, silent = true, desc = "Select word backward" })
vim.keymap.set('n', '<S-Right>', 'vw', { noremap = true, silent = true, desc = "Select word forward" })
vim.keymap.set({ 'v', 'x' }, '<S-Down>', 'j', { noremap = true, silent = true, desc = "Extend selection downward" })
vim.keymap.set({ 'v', 'x' }, '<S-Up>', 'k', { noremap = true, silent = true, desc = "Extend selection upward" })
vim.keymap.set({ 'v', 'x' }, '<S-Left>', 'b', { noremap = true, silent = true, desc = "Extend selection word backward" })
vim.keymap.set({ 'v', 'x' }, '<S-Right>', 'w', { noremap = true, silent = true, desc = "Extend selection word forward" })

-- Shift + Alt + J / K: Select multiple lines downward / upward (Insert, Normal, and Visual mode)
-- Insert mode: start selection and step downward / upward
vim.keymap.set('i', '<M-S-j>', function() start_selection_from_insert("j") end, { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set('i', '<M-J>',   function() start_selection_from_insert("j") end, { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set('i', '<M-S-k>', function() start_selection_from_insert("k") end, { noremap = true, silent = true, desc = "Select line upward" })
vim.keymap.set('i', '<M-K>',   function() start_selection_from_insert("k") end, { noremap = true, silent = true, desc = "Select line upward" })

-- Shift + Arrows from Insert mode: start selection and track insert origin
vim.keymap.set('i', '<S-Down>',  function() start_selection_from_insert("j") end, { noremap = true, silent = true, desc = "Select line downward (Insert)" })
vim.keymap.set('i', '<S-Up>',    function() start_selection_from_insert("k") end, { noremap = true, silent = true, desc = "Select line upward (Insert)" })
vim.keymap.set('i', '<S-Left>',  function() start_selection_from_insert("b") end, { noremap = true, silent = true, desc = "Select word backward (Insert)" })
vim.keymap.set('i', '<S-Right>', function() start_selection_from_insert("w") end, { noremap = true, silent = true, desc = "Select word forward (Insert)" })

-- Normal mode: start selection and step downward / upward
vim.keymap.set('n', '<M-S-j>', 'vj', { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set('n', '<M-J>',   'vj', { noremap = true, silent = true, desc = "Select line downward" })
vim.keymap.set('n', '<M-S-k>', 'vk', { noremap = true, silent = true, desc = "Select line upward" })
vim.keymap.set('n', '<M-K>',   'vk', { noremap = true, silent = true, desc = "Select line upward" })

-- Visual / Selection mode: extend selection downward / upward
vim.keymap.set({ 'v', 'x' }, '<M-S-j>', 'j', { noremap = true, silent = true, desc = "Extend selection downward" })
vim.keymap.set({ 'v', 'x' }, '<M-J>',   'j', { noremap = true, silent = true, desc = "Extend selection downward" })
vim.keymap.set({ 'v', 'x' }, '<M-S-k>', 'k', { noremap = true, silent = true, desc = "Extend selection upward" })
vim.keymap.set({ 'v', 'x' }, '<M-K>',   'k', { noremap = true, silent = true, desc = "Extend selection upward" })

-- Join lines: J is taken by downward selection, so joining lives elsewhere
vim.keymap.set('n', 'gJ', 'J', { noremap = true, silent = true, desc = "Join Lines" })

-- Guard against an accidental `dgg` when <C-d> is followed by gg
vim.keymap.set('n', 'dgg', 'gg', { noremap = true, silent = true, desc = "Prevent accidental deletion from <C-d> + gg rollover" })

-- =========================================================================
-- 6. VS CODE-STYLE COPY / CUT / PASTE
-- =========================================================================
vim.keymap.set({ 'v', 'x', 's' }, 'y', visual_yank, { noremap = true, silent = true, desc = "Yank selection" })
vim.keymap.set({ 'v', 'x', 's' }, 'Y', visual_yank, { noremap = true, silent = true, desc = "Yank selection" })
vim.keymap.set({ 'v', 'x', 's' }, '<C-c>', visual_yank, { noremap = true, silent = true, desc = "Copy selection" })
vim.keymap.set('n', '<C-c>', 'yy', { noremap = true, silent = true, desc = "Copy Line" })
vim.keymap.set('i', '<C-c>', '<C-o>yy', { noremap = true, silent = true, desc = "Copy Line" })
vim.keymap.set({ 'v', 'x', 's' }, 'd', visual_cut, { noremap = true, silent = true, desc = "Cut selection" })
vim.keymap.set({ 'v', 'x', 's' }, 'x', visual_cut, { noremap = true, silent = true, desc = "Cut selection" })
vim.keymap.set({ 'v', 'x', 's' }, '<C-x>', visual_cut, { noremap = true, silent = true, desc = "Cut selection" })
vim.keymap.set('n', '<C-x>', 'dd', { noremap = true, silent = true, desc = "Cut Line" })
vim.keymap.set('i', '<C-x>', '<C-o>dd', { noremap = true, silent = true, desc = "Cut Line" })
vim.keymap.set('i', '<C-v>', '<C-r>+', { noremap = true, silent = true, desc = "Paste" })

vim.keymap.set('n', '<leader>U', function()
  print("Updating plugins...")
  vim.cmd("Lazy update")
end, { noremap = true, silent = true, desc = "Update Plugins (Lazy)" })

-- =========================================================================
-- 7. TERMINALS (toggleterm, lazygit)
-- =========================================================================
local _lazygit_instance = nil
function _lazygit_toggle()
  local status_ok, tt_api = pcall(require, "toggleterm.terminal")
  if not status_ok then return end
  if not _lazygit_instance then
    _lazygit_instance = tt_api.Terminal:new({ cmd = "lazygit", hidden = true, direction = "float", float_opts = { border = "curved" } })
  end
  _lazygit_instance:toggle()
end
vim.keymap.set('n', '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true, desc = "Toggle Lazygit" })

local function get_terms()
  local status_ok, tt_api = pcall(require, "toggleterm.terminal")
  if not status_ok then return {} end
  local terms = {}
  for _, t in pairs(tt_api.get_all()) do table.insert(terms, t) end
  table.sort(terms, function(a, b) return a.id < b.id end)
  return terms
end

function _G.Update_Term_Winbar(win_id)
  if not win_id or not vim.api.nvim_win_is_valid(win_id) then return end
  local terms = get_terms()
  local bar = "  "
  for _, t in ipairs(terms) do
    if t.window and t.window == win_id then bar = bar .. "%#String# ● Term " .. t.id .. " %#Normal#  "
    else bar = bar .. "%#Comment# ○ Term " .. t.id .. " %#Normal#  " end
  end
  local buf = vim.api.nvim_win_get_buf(win_id)
  if vim.bo[buf].filetype == "toggleterm" then pcall(vim.api.nvim_set_option_value, 'winbar', bar, { win = win_id }) end
end

function _G.Term_New()
  local terms = get_terms()
  local max_id = 0
  for _, t in ipairs(terms) do if t.id > max_id then max_id = t.id end; if t:is_open() then t:close() end end
  vim.cmd((max_id + 1) .. "ToggleTerm direction=float")
end

function _G.Term_Next()
  local terms = get_terms()
  if #terms <= 1 then return end
  for i, t in ipairs(terms) do
    if t:is_open() then
      local next_term = terms[i + 1] or terms[1]
      t:close(); next_term:open(); vim.cmd("startinsert!")
      return
    end
  end
end

function _G.Term_Prev()
  local terms = get_terms()
  if #terms <= 1 then return end
  for i, t in ipairs(terms) do
    if t:is_open() then
      local prev_term = terms[i - 1] or terms[#terms]
      t:close(); prev_term:open(); vim.cmd("startinsert!")
      return
    end
  end
end

function _G.Term_Close()
  local terms = get_terms()
  if #terms == 0 then return end
  for i, t in ipairs(terms) do
    if t:is_open() then
      if #terms == 1 then t:shutdown()
      else
        local next_term = terms[i + 1] or terms[i - 1]
        t:shutdown(); next_term:open()
      end
      vim.defer_fn(function()
        local open_terms = get_terms()
        for _, remaining_t in ipairs(open_terms) do
          if remaining_t:is_open() and remaining_t.window and vim.api.nvim_win_is_valid(remaining_t.window) then
            _G.Update_Term_Winbar(remaining_t.window)
          end
        end
        vim.cmd("startinsert!")
      end, 50)
      return
    end
  end
end

vim.keymap.set('t', '<M-t>', '<cmd>lua _G.Term_New()<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<M-w>', '<cmd>lua _G.Term_Close()<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<M-]>', '<cmd>lua _G.Term_Next()<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<M-[>', '<cmd>lua _G.Term_Prev()<CR>', { noremap = true, silent = true })
