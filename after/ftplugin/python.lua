-- Python buffer options: Black-style 4-space indentation using spaces, never tabs.
-- Hanging-indent rules live in `vim.g.python_indent` in init.lua.
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.smarttab = true
-- Let `gq` format through conform.
vim.opt_local.formatexpr = "v:lua.require'conform'.formatexpr()"
