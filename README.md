# Neovim Configuration

A single-file Neovim setup built on [lazy.nvim](https://github.com/folke/lazy.nvim). It targets **Neovim 0.12+** and is tuned for the [Ghostty](https://ghostty.org) terminal on Linux. Parts of it also handle macOS and Windows paths.

The whole config lives in `init.lua`, split into numbered sections:

| Section | Contents |
| --- | --- |
| 0 | Startup tuning (bytecode cache, GC pause, disabled built-in plugins) and `PATH` setup |
| 1 | lazy.nvim bootstrap and the leader key (`Space`) |
| 2 | Plugin specifications |
| 3 | LSP server configuration (native `vim.lsp.config` / `vim.lsp.enable`) and the `Tool_Progress` notifier |
| 4 | Editor options, autocmds, file/layout guards, external-change watching, and jupytext sync |
| 5 | Commands and keymaps, plus `BinaryGuard` (binary, document and large-file handling) |
| 6 | VS Code-style copy / cut / paste |
| 7 | Terminals (toggleterm, lazygit) |

`after/ftplugin/python.lua` holds the Python buffer options (4-space indent, conform `formatexpr`). `lazy-lock.json` pins plugin versions.

## Installation

```sh
git clone <repo-url> ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself on first launch and installs the plugins. Run `:checkhealth` afterwards to see which external tools are missing.

### Requirements

- Neovim 0.12 or newer, and `git`
- A [Nerd Font](https://www.nerdfonts.com) set in the terminal
- [`fzf`](https://github.com/junegunn/fzf) and [`fd`](https://github.com/sharkdp/fd) (fuzzy finding and directory browsing)
- A C compiler (treesitter parsers)
- Optional: `lazygit`, ImageMagick (`magick`) for images, `jupytext` / `jupyter` for notebooks, `duckdb` (or `pqrs` / `parquet-tools`) for previewing data files, LibreOffice (`soffice`) for `.docx` previews

See [Installing dependencies (Linux)](#installing-dependencies-linux) at the end of this file for the exact commands, which pick the fastest install source for each tool on Fedora.

### Language servers and formatters

Servers are enabled in section 3 and must be installed and on `PATH`. The config does not install them.

| Language | Server | Formatter |
| --- | --- | --- |
| TypeScript / JavaScript | `vtsls`, `oxlint` | `oxfmt` |
| CSS, HTML, JSON, YAML, Markdown | | `oxfmt` |
| Python | `basedpyright` | `black` |
| C / C++ | `clangd` | `clang-format` |
| Rust | `rust-analyzer` | `rustfmt` |
| Go | `gopls` | `gofmt` |
| Java | `jdtls` | `google-java-format` |
| LaTeX | `texlab` | |
| TOML | `taplo` | `taplo` |

Format-on-save is on (via conform.nvim) and falls back to the LSP formatter. Formatter errors show up as diagnostics and quickfix entries. Use `:ConformErrors` or `<leader>ce` to review them.

oxfmt follows the nearest formatting config between the file and its project root. That can be an oxfmt config (`.oxfmtrc.json`, `.oxfmtrc.jsonc`, `oxfmt.config.ts` and the other `oxfmt.config.*` variants) or a Prettier config (`.prettierrc*`, `prettier.config.*`, or a `"prettier"` key in `package.json`). Prettier configs are converted with oxfmt's own `--migrate=prettier` into a cache directory, so nothing is written to the project. Projects with neither use the global style in `formatters/oxfmt.json` (oxfmt's defaults: 2-space indent, double quotes, 100 columns). A project's `.editorconfig` still sets indentation, line width and line endings on top of the global style.

## Plugins

| Area | Plugins |
| --- | --- |
| Appearance | tokyonight (OLED, transparent), lualine, bufferline, dropbar, noice, dressing, nvim-highlight-colors, mini.indentscope, nvim-scrollbar, smear-cursor |
| Navigation | nvim-tree, aerial (code outline), fzf-lua, flash, which-key |
| Editing | blink.cmp, mini.pairs, mini.bufremove, conform, treesitter |
| Git | gitsigns, lazygit (through toggleterm) |
| Diagnostics and debugging | trouble, nvim-dap with dap-ui and delve (Go) |
| Notebooks and media | molten-nvim, image.nvim, pdfpreview.nvim, render-markdown, rainbow_csv |
| Sessions and terminal | auto-session, alpha (dashboard), toggleterm |

Most plugins load lazily, on a command, key, filetype, or `VeryLazy`. `image.nvim` only loads when an image file is opened. `pdfpreview.nvim` loads at startup so it can take over `.pdf` buffers.

## Key features

- **Projects and sessions.** The dashboard and auto-session save and restore tabs and buffers per project. `<leader>p` restores an active project, and `<leader>fp` opens a recent one in NvimTree.
- **Sidebar layout.** NvimTree and Aerial keep fixed widths and never take over the window when the last file closes. `<M-e>` and `<M-S-e>` cycle focus between the tree, the code window and the outline.
- **Tool progress.** Work that never arrives as LSP progress shows in the bottom-right corner in the same style: formatter runs (black, oxfmt, rustfmt and the rest), slow diagnostic re-checks after an edit (vtsls, basedpyright, texlab), jupytext and LibreOffice conversions, NvimTree background deletes, and lazy.nvim's update check.
- **Notebooks.** `.ipynb` files open as `py:percent` scripts through jupytext and are converted back on save. Molten runs cells inline.
- **PDF and Word documents.** PDFs render page by page inside the buffer through the Kitty graphics protocol: `j`/`k` scroll, `h`/`l` pan, `+`/`-` zoom, `0` fits the width, `{n}G` jumps to a page and `q` closes. A `.docx` file offers to convert to PDF with LibreOffice for the same preview, or to open in the OS viewer. This needs a terminal that supports the Kitty graphics protocol, such as Ghostty.
- **Binary and large files.** Known binary types open in the OS viewer, and data files (parquet and similar) show a text preview. Unknown binaries are refused after a NUL-byte check. Files over 2 MB skip syntax, treesitter and LSP.
- **External changes.** Files changed or deleted on disk are detected on focus, buffer switch and idle, without the blocking E211 prompt.
- **Terminal buffers.** Terminals hide editor chrome and keep a large scrollback. A mouse drag selects and copies to the system clipboard. Hold Shift while dragging to use Ghostty's own selection instead. `Ctrl+Click` opens a URL, including one that wraps across lines.
- **VS Code-style editing.** Shift+motion keys select, `Ctrl+C/X/V` copy, cut and paste, `Ctrl+Z` undoes and `Ctrl+S` saves. Alt+h/j/k/l move the cursor without leaving Insert mode, `Alt+u` escapes, and `Alt+b` / `Alt+Backspace` delete backwards without dropping to Normal mode.

## Keymaps

The leader key is `Space`. Press it and wait to see every mapping in which-key. The most useful ones:

| Key | Action |
| --- | --- |
| `<leader>f` / `<leader>F` | Find files / find text |
| `<C-f>` | Fuzzy find in the current file |
| `<leader>d`, `<leader>fd` | Browse directories |
| `<leader>p` / `<leader>fp` | Restore an active project / open a recent project |
| `<leader>h` | Save the session and return to the dashboard |
| `<leader>e` | Toggle the file explorer (adopts the file's project first if none is active) |
| `<leader>a` | Toggle the Aerial code outline |
| `<Tab>` / `<S-Tab>` | Next / previous buffer tab |
| `<leader>w` / `<leader>q` | Close the file or split / quit from the dashboard |
| `<leader>o` | Open the current file in the OS viewer |
| `gd`, `gr`, `gh` | LSP definition, references (fzf), hover |
| `<leader>ca` / `<leader>rn` | Code action / rename |
| `<leader>xx` | Diagnostics panel (Trouble) |
| `<leader>cf` / `<leader>ce` | Format the buffer or selection / formatter errors to quickfix |
| `<leader>gg` | Lazygit |
| `<leader>gb` | Toggle inline git blame |
| `<leader>G` | Open the git remote in the browser |
| `<leader>th` / `<leader>tv` | Horizontal / vertical terminal |
| `<C-\>` | Toggle a floating terminal |
| `<M-t>`, `<M-w>`, `<M-]>`, `<M-[>` | New / close / next / previous terminal (Terminal mode) |
| `<leader>mi`, `<leader>rc`, `<leader>ro` | Molten: init kernel, run cell, show output |
| `<leader>mp` | Toggle Markdown rendering |
| `<leader>uc` / `<leader>us` | Toggle cursor smear / scrollbar |
| `<leader>U` | Update plugins |

Debugging (Go/delve) uses `<leader>d…`:

| Key | Action |
| --- | --- |
| `dc` | Start or continue |
| `db` / `dB` | Toggle breakpoint / conditional breakpoint |
| `dn` / `di` / `do` | Step over / into / out |
| `dt` / `dT` | Debug the nearest test / rerun the last test |
| `du` / `dr` / `de` | Toggle the UI / REPL / evaluate an expression |
| `dq` | Terminate the session |

Search is literal by default: `/` and `?` are prefixed with `\V`.

## Commands

| Command | Description |
| --- | --- |
| `:Format` | Format the buffer or visual selection |
| `:ConformErrors` | Load recent formatter errors into quickfix |
| `:AsyncDelete [path]` | Delete a file or folder in the background |
| `:CleanDeletedBuffers` | Close unmodified buffers whose file was deleted on disk |
| `:ClearProjects` | Remove the legacy project history file |

## Customising

- Add or remove a plugin in the `require("lazy").setup({ ... })` table (section 2).
- Add a language server with a `vim.lsp.config("name", { ... })` block and a matching `vim.lsp.enable("name")` (section 3), and a formatter in `formatters_by_ft` in the conform spec.
- Toggle the extras (cursor smear, scrollbar, blame) with the `<leader>u…` and `<leader>gb` keys, or delete their specs to remove them.
- Update plugins with `:Lazy update` (or `<leader>U`), and commit `lazy-lock.json` to keep installs reproducible.
- Follow the comment conventions below when adding code.

### Comment conventions

Comments in `init.lua` and `after/ftplugin/python.lua` follow one style:

- Explain *why*, not what the next line already says.
- Use complete sentences: capitalised, ending in a period. Plugin and section titles are short labels without a period.
- Wrap at 100 columns.
- Document functions with LuaLS annotations (`---` description, then `---@param` / `---@return`).
- Put long explanations above the code rather than trailing it. Short trailing comments are fine for a single option.
- Number steps (`1.`, `2.`) only when the order matters.

## Installing dependencies (Linux)

This section covers every item from [Requirements](#requirements) and [Language servers and formatters](#language-servers-and-formatters). It is written for Fedora. Each tool uses the fastest source available: **native compiled binaries** (Rust, Go, C/C++) from `dnf`, `cargo` or `go install`, and JavaScript tooling from `pnpm`. Where a tool has a compiled replacement for a slower default, that one is used.

### Faster tools than the defaults

The config prefers compiled tools over Neovim's built-in or scripted equivalents:

| Tool | Replaces | Why it is faster | Used by |
| --- | --- | --- | --- |
| `rg` (ripgrep) | `grep`, `:vimgrep` | Multi-threaded, respects `.gitignore`, and skips binary files | fzf-lua text search (`<leader>F`) |
| `fd` | `find` | Parallel directory walk with sane ignore defaults | Directory and project browsing (`<leader>d`, `<leader>fp`) |
| `fzf` | Vimscript/Lua pickers | A compiled Go finder that streams results without building Lua tables | All of fzf-lua |
| `oxlint` / `oxfmt` | ESLint / Prettier | Rust implementations, usually an order of magnitude faster | JS/TS linting and formatting |
| `vtsls` on TypeScript 7 | `typescript-language-server` on the JS compiler | Uses the native Go TypeScript compiler | JS/TS language server |
| `black`, `jupytext` via `uv` | `pip` installs | Isolated tool environments, installed in seconds | Python formatting and notebooks |
| `magick` | `convert` (ImageMagick 6) | Current ImageMagick 7 CLI | image.nvim |

### System packages (`dnf`)

These are best from the distribution: they are C/C++/Go/Rust binaries built and updated by Fedora.

```sh
sudo dnf install -y git neovim gcc make \
    fzf fd-find ripgrep \
    clang clang-tools-extra \
    ImageMagick
```

`clang-tools-extra` provides `clangd` and `clang-format`. Install a Nerd Font separately, from your font package or by unpacking it into `~/.local/share/fonts` and running `fc-cache -f`.

### Rust toolchain (`rustup` and `cargo`)

Install Rust with [rustup](https://rustup.rs), then add the components and the Cargo-built tools:

```sh
rustup component add rust-analyzer rustfmt clippy
cargo install --locked texlab taplo-cli pqrs
```

`cargo binstall` (if installed) downloads prebuilt binaries instead of compiling: `cargo binstall texlab taplo-cli pqrs`. `pqrs` is optional and only used to preview parquet files. Make sure `~/.cargo/bin` is on `PATH`. The config prepends it automatically.

### Go tools (`go install` and `gup`)

Install Go from `dnf install golang` or from [go.dev/dl](https://go.dev/dl). Then install the Go tools and keep them current with [gup](https://github.com/nao1215/gup):

```sh
go install github.com/nao1215/gup@latest
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/jesseduffield/lazygit@latest

gup list        # show installed Go binaries and their versions
gup update      # update all of them to the latest release
```

`gofmt` ships with Go itself. Binaries land in `~/go/bin`, which the config adds to `PATH`.

### JavaScript tooling (`pnpm`)

Install `pnpm` first (`dnf install pnpm`, or the [standalone script](https://pnpm.io/installation)), run `pnpm setup` once, then:

```sh
pnpm add -g typescript @vtsls/language-server basedpyright oxlint oxfmt
```

This gives `vtsls`, `basedpyright-langserver`, `oxlint` and `oxfmt` in `~/.local/share/pnpm/bin`. Update them with `pnpm update -g`.

### Python tools (`uv`)

Install [uv](https://docs.astral.sh/uv/) (`dnf install uv` or its install script). Each tool gets its own isolated environment:

```sh
uv tool install black
uv tool install jupytext
uv tool install jupyter-core   # provides the `jupyter` command used for notebook upgrades
uv tool install ruff           # optional
```

Update everything with `uv tool upgrade --all`. If `jupytext` is missing, the config falls back to `uvx jupytext` automatically.

### Optional tools

- **Java.** `jdtls` and `google-java-format` are only needed for Java work. Download the [Eclipse JDT LS](https://github.com/eclipse-jdtls/eclipse.jdt.ls) release and the [google-java-format](https://github.com/google/google-java-format/releases) jar, and put wrapper scripts named `jdtls` and `google-java-format` on `PATH`.
- **Document previews.** `.docx` files are converted to PDF with LibreOffice: `sudo dnf install -y libreoffice-writer` provides `soffice`.
- **Data previews.** `duckdb` is the preferred previewer for parquet and other data files. Download the CLI from [duckdb.org](https://duckdb.org/docs/installation/) into `~/.local/bin`. The config falls back to `pqrs`, then `parquet-tools`.

### Verify

```sh
for t in nvim git fzf fd rg lazygit magick soffice clangd clang-format \
         rust-analyzer rustfmt gopls gofmt dlv texlab taplo \
         vtsls basedpyright-langserver oxlint oxfmt black jupytext; do
  command -v "$t" >/dev/null && echo "ok      $t" || echo "MISSING $t"
done
```

Then open Neovim and run `:checkhealth` and `:Lazy`.

