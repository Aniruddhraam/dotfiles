# Shortcuts

Press `?` in Normal mode to open or close this sheet. It is read-only.
Search it with `/` (then `n` / `N` for the next / previous match), or `<C-f>` for a fuzzy search.
Close it with `?`, `q` or `<leader>w`. The leader key is `Space`: press it and wait to see every mapping in which-key.

## Files and search

| Key | Action |
| --- | --- |
| `<leader>f` | Find files |
| `<leader>F` | Find text in the project (live grep) |
| `<C-f>` | Fuzzy find in the current file |
| `<leader>d`, `<leader>fd`, `<leader>fb` | Browse directories |
| `/` | Literal search forward (`\V` is added for you) |
| `<Esc>` | Clear the search highlight, stop a snippet |
| `<leader>o` | Open the current file in the OS viewer |
| `<C-LeftMouse>` | Open the link under the mouse (URL, file, Markdown heading) |

## Projects and sessions

| Key | Action |
| --- | --- |
| `<leader>p` | Restore an active project (with its tabs) |
| `<leader>fp` | Open a recent project folder in the file explorer |
| `<leader>h` | Save the session and return to the dashboard |
| `<leader>q` | Quit Neovim (from the dashboard only) |

## Tabs, panes and sidebars

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Next / previous file tab |
| `<leader>w` | Close the file (and its split) |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Focus the pane left / below / above / right |
| `<M-e>` / `<M-S-e>` | Cycle focus: file, outline, tree (forward / reverse) |
| `<leader>e` | Toggle the file explorer (NvimTree) |
| `<leader>a` | Toggle the code outline (Aerial) |
| `<leader>xx` | Toggle the diagnostics panel (Trouble) |

## Editing (VS Code style)

| Key | Action |
| --- | --- |
| `<C-s>` | Save |
| `<C-z>` / `<C-y>` | Undo / redo |
| `<C-c>` | Copy the line, or the selection |
| `<C-x>` | Cut the line, or the selection |
| `<C-v>` | Paste (Insert mode) |
| `gc` / `gcc` | Toggle a comment on a motion or selection / on the line |
| `gJ` | Join lines (`J` selects instead) |
| `s` / `S` | Flash jump / Flash treesitter selection |

## Selecting

| Key | Action |
| --- | --- |
| `<S-Left>` / `<S-Right>` | Select a word backward / forward |
| `<S-Up>` / `<S-Down>` | Select a line upward / downward |
| `H` / `L` | Select a word backward / forward |
| `K` / `J` | Select a line upward / downward |
| `B` / `W` | Select a WORD backward / forward |
| `<M-K>` / `<M-J>` | Select a line upward / downward (also from Insert mode) |
| `<M-H>` / `<M-L>` | Extend the selection to the line start / end |
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | Cancel the selection and move |
| `y` | Yank the selection (to the system clipboard) |
| `d`, `x` | Cut the selection |
| `p`, `P` | Paste over the selection (keeps the clipboard) |
| `<BS>`, `<Del>` | Delete the selection (keeps the clipboard) |

## Insert mode

| Key | Action |
| --- | --- |
| `<M-h>` `<M-j>` `<M-k>` `<M-l>` | Move the cursor |
| `<M-w>` / `<M-W>` | Move a word forward / backward |
| `<C-h>` / `<C-l>` | Go to the line start / end |
| `<M-H>` / `<M-L>` | Go to the first character / line end |
| `<M-b>`, `<M-BS>` | Backspace |
| `<C-BS>` | Delete the previous word |
| `<M-o>` | Run one Normal-mode command |
| `<M-u>` | Escape |

## Completion

| Key | Action |
| --- | --- |
| `<Tab>` / `<S-Tab>` | Next / previous item, or the next / previous snippet field |
| `<CR>` | Accept |
| `<C-space>` | Show completion or documentation |
| `<C-e>` | Hide the menu |
| `<C-b>` / `<C-f>` | Scroll the documentation |

## Code (LSP)

| Key | Action |
| --- | --- |
| `gd`, `<C-]>` | Go to definition |
| `gr` | References (fzf) |
| `gh`, `<leader>k` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename the symbol |
| `[d` / `]d` | Previous / next diagnostic |
| `<C-w>d` | Show the diagnostics under the cursor |
| `<leader>cf` | Format the buffer or selection |
| `<leader>ce` | Formatter errors to quickfix |

## Git

| Key | Action |
| --- | --- |
| `<leader>gg` | Lazygit |
| `<leader>gb` | Toggle inline git blame |
| `<leader>G` | Open the git remote in the browser |

## Terminals

| Key | Action |
| --- | --- |
| `<C-\>` | Toggle a floating terminal |
| `<leader>th` / `<leader>tv` | Horizontal / vertical terminal |
| `<M-t>` / `<M-w>` | New / close terminal (Terminal mode) |
| `<M-]>` / `<M-[>` | Next / previous terminal (Terminal mode) |
| `<M-k>` / `<M-j>` | Previous / next shell command (Terminal mode) |
| `<Esc><Esc>` | Leave Terminal mode |

## Debugging (Go / delve)

| Key | Action |
| --- | --- |
| `<leader>dc` | Start or continue |
| `<leader>db` / `<leader>dB` | Toggle a breakpoint / conditional breakpoint |
| `<leader>dn` / `<leader>di` / `<leader>do` | Step over / into / out |
| `<leader>dt` / `<leader>dT` | Debug the nearest test / rerun the last test |
| `<leader>du` / `<leader>dr` | Toggle the DAP UI / REPL |
| `<leader>de` | Evaluate an expression |
| `<leader>dq` | Terminate the session |

## Notebooks (Molten)

| Key | Action |
| --- | --- |
| `<leader>mi` | Initialize a Jupyter kernel |
| `<leader>rc` / `<leader>rr` | Run / rerun the cell |
| `<leader>r` | Run the selection (Visual mode) |
| `<leader>ro` / `<leader>rd` | Show / delete the cell output |

## Toggles

| Key | Action |
| --- | --- |
| `<leader>mp` | Markdown rendering |
| `<leader>uc` | Cursor smear |
| `<leader>us` | Scrollbar |
| `<leader>U` | Update plugins |

## Inside special buffers

| Where | Key | Action |
| --- | --- | --- |
| File explorer | `q` | Return to the code |
| File explorer | `d`, `D` | Delete to the trash in the background |
| File explorer, outline, diagnostics | `g?` | Help |
| Outline | `<CR>` / `o` | Collapse or expand / jump to the symbol |
| Image | `q` / `o` | Close / open in the OS viewer |
| PDF | `j` / `k` | Scroll pages |
| PDF | `h` / `l` | Pan |
| PDF | `+` / `-` / `0` | Zoom in / out / fit the width |
| PDF | `{n}G` / `q` | Jump to page n / close |

## Commands

| Command | Description |
| --- | --- |
| `:Format` | Format the buffer or visual selection |
| `:ConformErrors` | Load recent formatter errors into quickfix |
| `:AsyncDelete [path]` | Delete a file or folder in the background |
| `:CleanDeletedBuffers` | Close unmodified buffers whose file was deleted on disk |
| `:ClearProjects` | Remove the legacy project history file |
