-- Python indentation that keeps working with treesitter highlighting.
--
-- The runtime indent script ($VIMRUNTIME/autoload/python.vim) asks the legacy syntax engine whether
-- a bracket or `#` is inside a string or comment. init.lua turns that engine off once treesitter
-- starts, so the script took the "(" in `if c == "(":` for an open bracket. Every line after it was
-- then lined up under that "(" until a `")"` string closed it. This is the same algorithm, with
-- treesitter answering instead. Hanging-indent amounts come from `vim.g.python_indent` in init.lua.
vim.bo.indentexpr = "v:lua.Python_Indent(v:lnum)"

local MAX_LOOKBACK = 50 -- Lines searched backwards for an open bracket, as in the runtime script.
local NOT_CODE = { string = true, string_content = true, comment = true }
local STRING_CONTENT = { string_content = true }
local STOP = vim.regex([[^\s*\(break\|continue\|raise\|return\|pass\)\>]])
local EXCEPT = vim.regex([[^\s*\(except\|finally\)\>]])
local TRY = vim.regex([[^\s*\(try\|except\)\>]])
local ELSE = vim.regex([[^\s*\(elif\|else\)\>]])
local ONE_LINER = vim.regex([[^\s*\(for\|if\|elif\|try\)\>]])
-- Parsed on first use, once the python parser is known to be installed. False if it fails.
local string_starts ---@type vim.treesitter.Query|false|nil

--- Read a `vim.g.python_indent` key, then the old `g:pyindent_` variable, then the runtime default.
---@param key string
---@param default any
---@return any
local function setting(key, default)
  local value = (vim.g.python_indent or {})[key]
  if value == nil then value = vim.g["pyindent_" .. key] end
  if value == nil then return default end
  return value
end

--- Read an indent amount, which may be an expression such as "shiftwidth()".
---@param key string
---@param default string
---@return integer
local function amount(key, default)
  local value = setting(key, default)
  return type(value) == "string" and vim.fn.eval(value) or value
end

--- Read an on/off setting. Vimscript may store it as 0 or 1.
---@param key string
---@param default boolean
---@return boolean
local function enabled(key, default)
  local value = setting(key, default)
  return value == true or (type(value) == "number" and value ~= 0)
end

--- Compute the indent of line `lnum` for 'indentexpr'. -1 keeps the indent the line already has.
---@param lnum integer
---@return integer
function _G.Python_Indent(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  -- Large files skip treesitter (see BinaryGuard), so they get the runtime script.
  local parser = vim.treesitter.highlighter.active[bufnr]
    and vim.treesitter.get_parser(bufnr, "python", { error = false })
  -- Parse now: keys typed faster than a redraw (a paste, a macro) leave the tree behind the text.
  local tree = parser and (parser:parse() or {})[1]
  if not tree then return vim.fn["python#GetIndent"](lnum) end
  local root = tree:root()
  if string_starts == nil then
    local ok, query = pcall(vim.treesitter.query.parse, "python", "(string_start) @start")
    string_starts = ok and query
  end

  -- A string still being typed (a docstring, say) has no closing quotes yet. Treesitter leaves its
  -- opening quotes outside any string node and parses the text after them as code, but Python
  -- reads that text as string: to the end of the file after triple quotes, else to the line end.
  local open_quotes ---@type { row: integer, col: integer, triple: boolean }[]?

  --- Whether an opening quote with no closing one comes before a 0-based (row, col).
  ---@param row integer
  ---@param col integer
  ---@return boolean
  local function after_open_quote(row, col)
    if not open_quotes then
      open_quotes = {}
      -- Only a tree with errors can hold one, and every lookup is on line `lnum` or above it.
      if string_starts and root:has_error() then
        for _, node in string_starts:iter_captures(root, bufnr, 0, lnum) do
          if node:parent():type() ~= "string" then
            local start_row, start_col = node:start()
            local quote = vim.treesitter.get_node_text(node, bufnr):sub(-3)
            local triple = quote == '"""' or quote == "'''"
            table.insert(open_quotes, { row = start_row, col = start_col, triple = triple })
          end
        end
      end
    end
    for _, quote in ipairs(open_quotes) do
      if quote.row > row or (quote.row == row and quote.col >= col) then return false end
      if quote.triple or quote.row == row then return true end
    end
    return false
  end

  --- Whether the character at a 0-based (row, col) is part of a node of one of `types`, or of a
  --- string with no closing quotes yet.
  ---@param row integer
  ---@param col integer
  ---@param types table<string, boolean>
  ---@return boolean
  local function inside(row, col, types)
    local node = root:named_descendant_for_range(row, col, row, col + 1)
    while node do
      if types[node:type()] then return true end
      node = node:parent()
    end
    return after_open_quote(row, col)
  end

  local timeout = setting("searchpair_timeout", 150)
  --- Find the unclosed bracket before the cursor, skipping brackets in strings and comments.
  ---@param from integer
  ---@param flags string
  ---@return integer lnum
  ---@return integer col
  local function search_bracket(from, flags)
    local pos = vim.fn.searchpairpos("[[({]", "", "[])}]", flags, function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      return inside(cursor[1] - 1, cursor[2], NOT_CODE)
    end, math.max(0, from - MAX_LOOKBACK), timeout)
    return pos[1], pos[2]
  end

  local getline, indent, sw = vim.fn.getline, vim.fn.indent, vim.fn.shiftwidth()

  -- A line joined to the previous one with a backslash: indent it, or line it up with the
  -- previous joined line.
  local joined = getline(lnum - 1)
  if joined:sub(-1) == "\\" and not inside(lnum - 2, #joined - 1, NOT_CODE) then
    if lnum > 2 and getline(lnum - 2):sub(-1) == "\\" then return indent(lnum - 1) end
    return indent(lnum - 1) + amount("continue", "shiftwidth() * 2")
  end

  -- Inside a multi-line string, keep the indent as typed.
  if inside(lnum - 1, 0, STRING_CONTENT) then return -1 end

  local plnum = vim.fn.prevnonblank(lnum - 1)
  if plnum == 0 then return 0 end

  local plindent, plnumstart, parlnum = indent(plnum), plnum, 0
  if not enabled("disable_parentheses_indenting", false) then
    -- Inside brackets, align with the open bracket unless it ends its line.
    vim.fn.cursor(lnum, 1)
    local par, parcol = search_bracket(lnum, "nbW")
    if par > 0 then
      if parcol ~= #getline(par) then return parcol end
      local closes = getline(lnum):match("^%s*[%])}]")
      if closes and not enabled("closed_paren_align_last_line", true) then return indent(par) end
    end

    -- When the previous line is inside brackets, measure from the line that opened them.
    vim.fn.cursor(plnum, 1)
    parlnum = search_bracket(plnum, "nbW")
    if parlnum > 0 then plindent, plnumstart = indent(parlnum), parlnum end

    -- The first line inside brackets gets the hanging indent; later ones follow the line above.
    vim.fn.cursor(lnum, 1)
    local p = search_bracket(lnum, "bW")
    if p > 0 then
      if p == plnum then
        -- The search left the cursor on that bracket, so this looks for one around it.
        if search_bracket(lnum, "bW") > 0 then
          return indent(plnum) + amount("nested_paren", "shiftwidth()")
        end
        return indent(plnum) + amount("open_paren", "shiftwidth() * 2")
      end
      if plnumstart == p then return indent(plnum) end
      return plindent
    end
  end

  -- The previous line without its trailing comment.
  local pline = getline(plnum)
  local last = root:named_descendant_for_range(plnum - 1, #pline - 1, plnum - 1, #pline)
  if last and last:type() == "comment" then pline = pline:sub(1, select(2, last:start())) end

  -- A line ending in a colon opens a block.
  if pline:match(":%s*$") then return plindent + sw end

  -- After break, continue, raise, return or pass, dedent unless the line already is.
  if STOP:match_str(getline(plnum)) then
    if indent(lnum) <= indent(plnum) - sw then return -1 end
    return indent(plnum) - sw
  end

  -- except and finally line up with their try, or with the except before them.
  local line = getline(lnum)
  if EXCEPT:match_str(line) then
    for l = lnum - 1, 1, -1 do
      if TRY:match_str(getline(l)) then
        if indent(l) >= indent(lnum) then return -1 end
        return indent(l)
      end
    end
    return -1
  end

  -- elif and else dedent, unless the block above was a one-liner or the line is already dedented.
  if ELSE:match_str(line) then
    if ONE_LINER:match_str(getline(plnumstart)) then return plindent end
    if indent(lnum) <= plindent - sw then return -1 end
    return plindent - sw
  end

  -- After a bracketed construct, go back to the indent of the line that opened it.
  if parlnum > 0 then
    if indent(lnum) <= plindent - sw then return -1 end
    return plindent
  end

  return -1
end
