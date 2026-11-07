-- Numbered floating and split terminals, toggled the way toggleterm.nvim did it (this module
-- replaces that plugin). It is built only on Neovim's own API: jobstart({ term = true }) for the
-- job and nvim_open_win() or :split for the window.
--
-- Terminals get ids 1, 2, 3 and so on. Hidden terminals (lazygit) are kept out of that list, so
-- they never take an id that `:{N}ToggleTerm` or the terminal tabs expect to be a shell.
--
-- init.lua defines the keys and :ToggleTerm, :ToggleTermToggleAll and :TermExec, and loads this
-- file on first use.

local api, fn = vim.api, vim.fn

local M = {}

--- Filetype of every terminal buffer this module creates.
M.filetype = "terminals"

local config = {
  size = 12, -- split height (horizontal) or width (vertical); a number or fun(term): number
  direction = "horizontal", -- "float", "horizontal" or "vertical"
  open_mapping = nil, -- key that toggles from inside a terminal (Terminal mode)
  float_opts = { border = "rounded", winblend = 0 },
  start_in_insert = true,
  persist_mode = true, -- reopen a terminal in the mode (Terminal or Normal) it was left in
  persist_size = true, -- reopen splits at the size they had when closed
  close_on_exit = true, -- close the window and delete the buffer when the job exits
  auto_scroll = true, -- in Normal mode, keep an open terminal scrolled to the end as output arrives
  hide_numbers = true,
  on_open = nil, -- fun(term)
}

---@type table<integer, Terminal> numbered terminals by id
local terminals = {}
---@type table<integer, Terminal> every terminal (numbered or hidden) by buffer
local by_buf = {}
---@type table<string, integer> last split size per direction
local sizes = {}
-- Terminals closed by the last no-count toggle, reopened by the next one.
local view = { ids = {}, focus = nil }
-- Window that was current when a terminal opened; closing a split returns to it.
local origin_win

local group = api.nvim_create_augroup("LocalTerminals", { clear = true })

local function win_valid(win) return win ~= nil and api.nvim_win_is_valid(win) end
local function buf_valid(buf) return buf ~= nil and api.nvim_buf_is_valid(buf) end
local function is_float_win(win) return win_valid(win) and fn.win_gettype(win) == "popup" end
local function resolve(value, term) if type(value) == "function" then return value(term) end return value end
local function set_wo(win, name, value) api.nvim_set_option_value(name, value, { scope = "local", win = win }) end

local function next_id()
  local id = 1
  while terminals[id] do id = id + 1 end
  return id
end

local function resolve_dir(dir)
  if dir == "git_dir" then return vim.fs.root(vim.uv.cwd(), ".git") or vim.uv.cwd() end
  return dir and fn.expand(dir) or vim.uv.cwd()
end

local function update_origin(term_win)
  local cur = api.nvim_get_current_win()
  if term_win ~= cur then origin_win = cur end
end

--- Windows (in every tab) that show a terminal from this module.
---@return { window: integer, term: Terminal }[]
local function open_windows()
  local wins = {}
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
      local term = by_buf[api.nvim_win_get_buf(win)]
      if term then wins[#wins + 1] = { window = win, term = term } end
    end
  end
  return wins
end

local function define_highlights()
  -- Split terminals: a plain statusline (and italic when inactive), as toggleterm drew them.
  api.nvim_set_hl(0, "TerminalsStatusLine", {})
  api.nvim_set_hl(0, "TerminalsStatusLineNC", { cterm = { italic = true } })
end

---------------------------------------------------------------------------------------------------
-- Terminal
---------------------------------------------------------------------------------------------------

---@class Terminal
---@field id integer? position in the numbered list (nil for hidden terminals)
---@field cmd string|string[]? command to run instead of the shell
---@field dir string? working directory (defaults to the cwd when first opened)
---@field direction string "float", "horizontal" or "vertical"
---@field display_name string? float title
---@field hidden boolean
---@field float_opts table
---@field close_on_exit boolean
---@field auto_scroll boolean
---@field on_open fun(term: Terminal)?
---@field on_close fun(term: Terminal)?
---@field on_exit fun(term: Terminal, job: integer, code: integer)?
---@field bufnr integer?
---@field window integer?
---@field job_id integer?
---@field mode "i"|"n"|"?" mode to restore on the next enter (persist_mode)
local Terminal = {}
Terminal.__index = Terminal

--- Create a terminal object; nothing opens or runs until :open().
--- A numbered terminal whose id already exists is returned as is.
---@param opts? table fields of Terminal
---@return Terminal
function M.new(opts)
  opts = opts or {}
  local hidden = opts.hidden == true
  if not hidden and opts.id and terminals[opts.id] then return terminals[opts.id] end
  return setmetatable({
    id = not hidden and (opts.id or next_id()) or nil,
    cmd = opts.cmd,
    dir = opts.dir,
    direction = opts.direction or config.direction,
    display_name = opts.display_name,
    hidden = hidden,
    float_opts = vim.tbl_deep_extend("keep", opts.float_opts or {}, config.float_opts),
    close_on_exit = vim.F.if_nil(opts.close_on_exit, config.close_on_exit),
    auto_scroll = vim.F.if_nil(opts.auto_scroll, config.auto_scroll),
    on_open = vim.F.if_nil(opts.on_open, config.on_open),
    on_close = opts.on_close,
    on_exit = opts.on_exit,
    mode = "?",
  }, Terminal)
end

function Terminal:is_float() return self.direction == "float" and is_float_win(self.window) end

function Terminal:is_split()
  return (self.direction == "horizontal" or self.direction == "vertical") and not is_float_win(self.window)
end

function Terminal:is_open()
  if not win_valid(self.window) then return false end
  local kind = fn.win_gettype(self.window)
  return (kind == "" or kind == "popup") and api.nvim_win_get_buf(self.window) == self.bufnr
end

function Terminal:is_focused() return self.window == api.nvim_get_current_win() end

function Terminal:focus()
  if win_valid(self.window) then api.nvim_set_current_win(self.window) end
end

---@private
function Terminal:_add()
  if self.hidden then return end
  if terminals[self.id] and terminals[self.id] ~= self then self.id = next_id() end
  terminals[self.id] = self
end

---@private
function Terminal:_remove()
  if not self.hidden and terminals[self.id] == self then terminals[self.id] = nil end
end

---@private
function Terminal:_float_config(opening)
  local o = self.float_opts
  local width = math.ceil(math.min(vim.o.columns, math.max(80, vim.o.columns - 20)))
  local height = math.ceil(math.min(vim.o.lines, math.max(20, vim.o.lines - 10)))
  width = resolve(o.width, self) or width
  height = resolve(o.height, self) or height
  local cfg = {
    relative = o.relative or "editor",
    row = resolve(o.row, self) or math.ceil(vim.o.lines - height) * 0.5 - 1,
    col = resolve(o.col, self) or math.ceil(vim.o.columns - width) * 0.5 - 1,
    width = width,
    height = height,
    zindex = o.zindex,
  }
  if self.display_name then cfg.title, cfg.title_pos = self.display_name, o.title_pos or "left" end
  if opening then
    cfg.style = "minimal"
    cfg.border = (o.border == "curved" and "rounded") or o.border or "single"
  end
  return cfg
end

local split_cmds = {
  horizontal = { existing = "rightbelow vsplit", new = "botright split", resize = "resize", get = api.nvim_win_get_height },
  vertical = { existing = "rightbelow split", new = "botright vsplit", resize = "vertical resize", get = api.nvim_win_get_width },
}

local function save_size(direction, win)
  if split_cmds[direction] then sizes[direction] = split_cmds[direction].get(win) end
end

---@private
function Terminal:_resize(size)
  local valid = size ~= nil and size > 0
  size = valid and size or (config.persist_size and sizes[self.direction]) or config.size
  size = resolve(size, self)
  if config.persist_size and size then sizes[self.direction] = size end
  vim.cmd(split_cmds[self.direction].resize .. " " .. size)
end

---@private
function Terminal:_open_window(size)
  if not buf_valid(self.bufnr) then self.bufnr = api.nvim_create_buf(false, false) end
  if self.direction == "float" then
    self.window = api.nvim_open_win(self.bufnr, true, self:_float_config(true))
    set_wo(self.window, "sidescrolloff", 0)
    if self.float_opts.winblend then set_wo(self.window, "winblend", self.float_opts.winblend) end
  elseif split_cmds[self.direction] then
    -- A second split terminal opens beside the last one; otherwise along the editor's edge.
    local cmds = split_cmds[self.direction]
    local wins = open_windows()
    local last = wins[#wins]
    if last and not is_float_win(last.window) then
      if config.persist_size then save_size(self.direction, last.window) end
      api.nvim_set_current_win(last.window)
      vim.cmd(cmds.existing)
    else
      vim.cmd(cmds.new)
    end
    self:_resize(size)
    self.window = api.nvim_get_current_win()
    api.nvim_win_set_buf(self.window, self.bufnr)
  else
    error("Invalid terminal direction: " .. tostring(self.direction))
  end
end

---@private
function Terminal:_set_options()
  local bo = vim.bo[self.bufnr]
  if bo.filetype ~= M.filetype then bo.filetype = M.filetype end
  bo.buflisted = false
  local win = self.window
  if self:is_split() then set_wo(win, self.direction == "vertical" and "winfixwidth" or "winfixheight", true) end
  if config.hide_numbers then
    set_wo(win, "number", false)
    set_wo(win, "relativenumber", false)
  end
end

--- Runs after the job starts: Neovim's own TermOpen handler adds StatusLineTerm to winhighlight,
--- and this replaces that, as toggleterm did.
---@private
function Terminal:_set_highlights()
  local hl = "NormalFloat:Normal,FloatBorder:Normal"
  if not is_float_win(self.window) then hl = hl .. ",StatusLine:TerminalsStatusLine,StatusLineNC:TerminalsStatusLineNC" end
  set_wo(self.window, "winhighlight", hl)
end

---@private
function Terminal:_restore_mode()
  local m = self.mode
  if m == "n" then
    vim.schedule(function() vim.cmd("stopinsert") end)
  elseif m == "i" or config.start_in_insert then
    vim.schedule(function() vim.cmd("startinsert") end)
  end
end

---@private
function Terminal:_save_mode()
  local raw = api.nvim_get_mode().mode
  self.mode = raw:match("nt") and "n" or raw:match("t") and "i" or "?"
end

---@private
function Terminal:_scroll_bottom()
  if not self:is_open() then return end
  local mode = api.nvim_get_mode().mode
  if mode == "n" or mode == "nt" then api.nvim_win_call(self.window, function() vim.cmd("normal! G") end) end
end

---@private
function Terminal:_on_output()
  -- One scroll per batch of output, not one per chunk.
  if self._scroll_queued then return end
  self._scroll_queued = true
  vim.schedule(function()
    self._scroll_queued = false
    self:_scroll_bottom()
  end)
end

---@private
function Terminal:_on_exit(code)
  if self.on_exit then self:on_exit(self.job_id, code) end
  if self.close_on_exit then
    if self:is_open() then self:close() end
    if buf_valid(self.bufnr) then api.nvim_buf_delete(self.bufnr, { force = true }) end
  end
end

---@private
function Terminal:_on_enter()
  local buf = self.bufnr
  if vim.bo[buf].filetype ~= M.filetype then vim.bo[buf].filetype = M.filetype end
  -- If a terminal split is the last window left, show the next buffer in it instead.
  if fn.winnr("$") == 1 and self:is_split() and pcall(vim.cmd, "keepalt bnext") then return end
  if config.persist_mode then
    self:_restore_mode()
  elseif config.start_in_insert then
    vim.schedule(function() vim.cmd("startinsert") end)
  end
end

---@private
function Terminal:_on_leave()
  if config.persist_mode then self:_save_mode() end
  -- A floating terminal closes when focus moves elsewhere.
  if not self._closing and self:is_float() then self:close() end
end

--- Start the job in the terminal's buffer (which the current window shows).
---@private
function Terminal:_spawn()
  self:_add()
  local buf = self.bufnr
  -- The shell is started as a string, which runs through 'shell' ($SHELL -c $SHELL), as toggleterm
  -- did. Started directly, Neovim's own TermClose handler would delete the buffer on a clean exit
  -- before this module could close the window its own way.
  local cmd = self.cmd or vim.o.shell
  local dir = resolve_dir(self.dir)
  api.nvim_buf_call(buf, function()
    self.job_id = fn.jobstart(cmd, {
      term = true,
      detach = true,
      cwd = dir,
      on_exit = function(_, code) self:_on_exit(code) end,
      on_stdout = self.auto_scroll and function() self:_on_output() end or nil,
    })
  end)
  self.dir = dir
  by_buf[buf] = self

  if config.open_mapping then
    vim.keymap.set("t", config.open_mapping, function() M.toggle() end, { buffer = buf, silent = true, desc = "Toggle Terminal" })
  end
  api.nvim_create_autocmd("BufEnter", { group = group, buffer = buf, nested = true, callback = function() self:_on_enter() end })
  api.nvim_create_autocmd("WinLeave", { group = group, buffer = buf, callback = function() self:_on_leave() end })
  api.nvim_create_autocmd("TermClose", { group = group, buffer = buf, callback = function() self:_remove() end })
  api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = buf,
    callback = function()
      by_buf[buf] = nil
      self:_remove()
    end,
  })

  if config.start_in_insert and self.window == api.nvim_get_current_win() then vim.cmd("startinsert") end
end

--- Open the terminal's window, starting its job the first time.
---@param size integer? split size
---@param direction string? switch to this direction (it sticks for later opens)
function Terminal:open(size, direction)
  origin_win = api.nvim_get_current_win()
  if direction then
    self.direction = direction
    self.window = nil
  end
  self.dir = resolve_dir(self.dir)
  local fresh = not buf_valid(self.bufnr)
  local ok, err = pcall(self._open_window, self, size)
  if not ok then return vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Terminals" }) end
  self:_set_options()
  if fresh then self:_spawn() end
  self:_set_highlights()
  if self.on_open then self:on_open() end
end

--- Close the terminal's window; the job keeps running.
function Terminal:close()
  if self.on_close then self:on_close() end
  self._closing = true
  if self:is_split() then
    if win_valid(self.window) then
      if config.persist_size then save_size(self.direction, self.window) end
      pcall(api.nvim_win_close, self.window, true)
    end
    if win_valid(origin_win) then api.nvim_set_current_win(origin_win) else origin_win = nil end
  elseif win_valid(self.window) then
    pcall(api.nvim_win_close, self.window, true)
  end
  self._closing = false
  vim.cmd("stopinsert")
  update_origin(self.window)
end

function Terminal:toggle(size, direction)
  if self:is_open() then self:close() else self:open(size, direction) end
  return self
end

--- Close the window, end the job and remove the terminal from the list.
function Terminal:shutdown()
  if self:is_open() then self:close() end
  if buf_valid(self.bufnr) then api.nvim_buf_delete(self.bufnr, { force = true }) end
  self:_remove()
end

--- Send a line (or lines) to the job.
---@param cmd string|string[]
---@param go_back boolean? return to the previous window afterwards
function Terminal:send(cmd, go_back)
  local lines = type(cmd) == "table" and cmd or { cmd }
  fn.chansend(self.job_id, table.concat(lines, "\n") .. "\n")
  self:_scroll_bottom()
  if go_back and self:is_focused() then
    vim.cmd("wincmd p")
    vim.cmd("stopinsert")
  elseif not go_back and not self:is_focused() then
    self:focus()
  end
end

M.Terminal = Terminal

---------------------------------------------------------------------------------------------------
-- The list and toggling
---------------------------------------------------------------------------------------------------

---@param id integer?
---@return Terminal?
function M.get(id) return id and terminals[id] or nil end

--- Numbered terminals, sorted by id (hidden ones are not included).
---@return Terminal[]
function M.get_all()
  local list = {}
  for _, term in pairs(terminals) do list[#list + 1] = term end
  table.sort(list, function(a, b) return a.id < b.id end)
  return list
end

local function get_or_create(id, dir, direction, name)
  local term = M.get(id)
  if term then return term end
  if dir and dir ~= "git_dir" and fn.isdirectory(fn.expand(dir)) == 0 then dir = nil end
  return M.new({ id = id, dir = dir, direction = direction, display_name = name })
end

local function first_id()
  local first = M.get_all()[1]
  return first and first.id or nil
end

local function close_and_save_view(wins)
  local ids, seen = {}, {}
  local focused
  for _, w in ipairs(wins) do
    if w.term:is_focused() then focused = w.term end
  end
  for _, w in ipairs(wins) do
    local term = w.term
    if not term.hidden and terminals[term.id] == term and not seen[term] then
      seen[term] = true
      ids[#ids + 1] = term.id
      term:close()
    end
  end
  view = { ids = ids, focus = focused and focused.id or nil }
end

local function open_view(size, direction)
  if #view.ids == 0 then return false end
  local opened = false
  for _, id in ipairs(view.ids) do
    local term = terminals[id]
    if term then
      term:open(size, direction)
      opened = true
    end
  end
  local focus = view.focus and terminals[view.focus]
  if focus then focus:focus() end
  view = { ids = {}, focus = nil }
  return opened
end

--- With a count, toggle that terminal. Without one: close every open terminal, or reopen the
--- ones the last toggle closed, or open the first terminal (creating it if needed).
---@param count integer?
---@param size integer?
---@param dir string?
---@param direction string?
---@param name string?
function M.toggle(count, size, dir, direction, name)
  if count and count >= 1 then
    local term = get_or_create(count, dir, direction, name)
    update_origin(term.window)
    term:toggle(size, direction)
    if #open_windows() == 0 then view = { ids = { term.id }, focus = term.id } end
    return
  end
  local wins = open_windows()
  if #wins > 0 then
    close_and_save_view(wins)
  elseif not open_view(size, direction) then
    get_or_create(first_id(), dir, direction, name):open(size, direction)
  end
end

--- Close all terminals if any is open, otherwise open them all.
function M.toggle_all()
  local any_open = #open_windows() > 0
  for _, term in ipairs(M.get_all()) do
    if not any_open then
      term:open()
    elseif term:is_open() then
      term:close()
    end
  end
end

--- Send a command to terminal `num` (or the first one), opening it if needed.
function M.exec(cmd, num, size, dir, direction, name, go_back, open)
  num = (num and num >= 1) and num or first_id()
  open = open == nil or open
  local term = get_or_create(num, dir, direction, name)
  if not term:is_open() then term:open(size, direction) end
  -- Going back from a float would close it.
  if term:is_float() then go_back = false end
  if go_back == nil then go_back = true end
  if not open then
    term:close()
    go_back = false
  end
  term:send(cmd, go_back)
end

---------------------------------------------------------------------------------------------------
-- Command arguments
---------------------------------------------------------------------------------------------------

--- Parse `key=value` arguments; values may be quoted: cmd='git status' dir=~/src size=20
---@param args string
---@return { cmd: string?, dir: string?, direction: string?, size: integer?, name: string?, go_back: boolean?, open: boolean? }
function M.parse(args)
  local result = {}
  args = (args or ""):gsub("([%w_]+)=(['\"])(.-)%2", function(key, _, value)
    result[key] = fn.expandcmd(value)
    return ""
  end)
  for _, part in ipairs(vim.split(args, "%s+", { trimempty = true })) do
    local key, value = part:match("^([%w_]+)=(.*)$")
    if key then
      if key == "size" then
        value = tonumber(value)
      elseif key == "go_back" or key == "open" then
        value = value ~= "0"
      end
      result[key] = value
    end
  end
  return result
end

--- :ToggleTerm [direction=] [size=] [dir=] [name=]
function M.toggle_command(args, count)
  local p = M.parse(args)
  M.toggle(count, p.size, p.dir, p.direction, p.name)
end

--- :TermExec cmd='...' [direction=] [size=] [dir=] [name=] [go_back=0] [open=0]
function M.exec_command(args, count)
  local p = M.parse(args)
  if type(p.cmd) ~= "string" or p.cmd == "" then
    return vim.notify("TermExec needs a command, e.g. TermExec cmd='ls -l'", vim.log.levels.ERROR, { title = "Terminals" })
  end
  M.exec(p.cmd, count, p.size, p.dir, p.direction, p.name, p.go_back, p.open)
end

--- Completion for the command arguments.
---@param exec boolean include TermExec's keys
function M.complete(exec)
  return function(arglead)
    local key, value = arglead:match("^([%w_]+)=(.*)$")
    if key == "direction" then
      return vim.tbl_map(function(d) return "direction=" .. d end,
        vim.tbl_filter(function(d) return vim.startswith(d, value) end, { "float", "horizontal", "vertical" }))
    elseif key == "dir" then
      return vim.tbl_map(function(d) return "dir=" .. d end, fn.getcompletion(value, "dir"))
    end
    local keys = { "direction=", "size=", "dir=", "name=" }
    if exec then vim.list_extend(keys, { "cmd=", "go_back=0", "open=0" }) end
    return vim.tbl_filter(function(k) return vim.startswith(k, arglead) end, keys)
  end
end

---------------------------------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------------------------------

M.configured = false

---@param opts? table overrides for the defaults at the top of this file
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  M.configured = true
  define_highlights()
  api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_highlights })
  api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      for _, w in ipairs(open_windows()) do
        if w.window == w.term.window and w.term:is_float() then
          pcall(api.nvim_win_set_config, w.window, w.term:_float_config(false))
        end
      end
    end,
  })
end

return M
