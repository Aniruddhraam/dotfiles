# Neovim and Zsh Configuration

Two dotfiles in one repo: a single-file Neovim setup and a Zsh setup. The Neovim setup is built on [lazy.nvim](https://github.com/folke/lazy.nvim). It targets **Neovim 0.12+** and is tuned for the [Ghostty](https://ghostty.org) terminal on Linux. Parts of it also handle macOS and Windows paths. The Zsh setup (`zshrc`) is built on [Oh My Zsh](https://ohmyz.sh) and [Powerlevel10k](https://github.com/romkatv/powerlevel10k), and is written for Linux.

## Repository layout

| File | Purpose |
| --- | --- |
| `init.lua` | The whole Neovim configuration, split into numbered sections (see below) |
| `after/ftplugin/python.lua` | Python buffer options (4-space indent, conform `formatexpr`) |
| `after/indent/python.lua` | Python indentation that uses treesitter to ignore brackets and `#` inside strings and comments |
| `formatters/oxfmt.json` | Global oxfmt style, used when a project has no oxfmt or Prettier config |
| `lazy-lock.json` | Pinned plugin versions |
| `zshrc` | The Zsh configuration. Link it to `~/.zshrc` (see [Zsh configuration](#zsh-configuration)) |
| `p10k.zsh` | The Powerlevel10k prompt configuration. Link it to `~/.p10k.zsh` |

## Neovim configuration

`init.lua` is split into numbered sections:

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

### Installation

```sh
git clone <repo-url> ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself on first launch and installs the plugins. Run `:checkhealth` afterwards to see which external tools are missing. The `zshrc` in the same clone is installed separately; see [Zsh configuration](#zsh-configuration).

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

### Plugins

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

### Key features

- **Projects and sessions.** The dashboard and auto-session save and restore tabs and buffers per project. `<leader>p` restores an active project, and `<leader>fp` opens a recent one in NvimTree.
- **Sidebar layout.** NvimTree and Aerial keep fixed widths and never take over the window when the last file closes. `<M-e>` and `<M-S-e>` cycle focus between the tree, the code window and the outline.
- **Tool progress.** Work that never arrives as LSP progress shows in the bottom-right corner in the same style: formatter runs (black, oxfmt, rustfmt and the rest), slow diagnostic re-checks after an edit (vtsls, basedpyright, texlab), jupytext and LibreOffice conversions, NvimTree background deletes, and lazy.nvim's update check.
- **Notebooks.** `.ipynb` files open as `py:percent` scripts through jupytext and are converted back on save. Molten runs cells inline.
- **Python indentation.** Enter indents like Vim's own Python indent: one level after a colon, a hanging indent inside brackets, and a dedent after `return`, `pass`, `break`, `continue` and `raise`. Brackets and `#` inside strings and comments are ignored, including in a docstring that is not closed yet, so `if c == "(":` no longer pushes the next line under the `(`.
- **PDF and Word documents.** PDFs render page by page inside the buffer through the Kitty graphics protocol: `j`/`k` scroll, `h`/`l` pan, `+`/`-` zoom, `0` fits the width, `{n}G` jumps to a page and `q` closes. A `.docx` file offers to convert to PDF with LibreOffice for the same preview, or to open in the OS viewer. This needs a terminal that supports the Kitty graphics protocol, such as Ghostty.
- **Binary and large files.** Known binary types open in the OS viewer, and data files (parquet and similar) show a text preview. Unknown binaries are refused after a NUL-byte check. Files over 2 MB skip syntax, treesitter and LSP.
- **External changes.** Files changed or deleted on disk are detected on focus, buffer switch and idle, without the blocking E211 prompt.
- **Terminal buffers.** Terminals hide editor chrome and keep a large scrollback. A mouse drag selects and copies to the system clipboard. Hold Shift while dragging to use Ghostty's own selection instead. `Ctrl+Click` opens a URL, including one that wraps across lines.
- **VS Code-style editing.** Shift+motion keys select, `Ctrl+C/X/V` copy, cut and paste, `Ctrl+Z` undoes and `Ctrl+S` saves. Alt+h/j/k/l move the cursor without leaving Insert mode, `Alt+u` escapes, and `Alt+b` / `Alt+Backspace` delete backwards without dropping to Normal mode.

### Keymaps

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

### Commands

| Command | Description |
| --- | --- |
| `:Format` | Format the buffer or visual selection |
| `:ConformErrors` | Load recent formatter errors into quickfix |
| `:AsyncDelete [path]` | Delete a file or folder in the background |
| `:CleanDeletedBuffers` | Close unmodified buffers whose file was deleted on disk |
| `:ClearProjects` | Remove the legacy project history file |

### Customising

- Add or remove a plugin in the `require("lazy").setup({ ... })` table (section 2).
- Add a language server with a `vim.lsp.config("name", { ... })` block and a matching `vim.lsp.enable("name")` (section 3), and a formatter in `formatters_by_ft` in the conform spec.
- Toggle the extras (cursor smear, scrollbar, blame) with the `<leader>u…` and `<leader>gb` keys, or delete their specs to remove them.
- Update plugins with `:Lazy update` (or `<leader>U`), and commit `lazy-lock.json` to keep installs reproducible.
- Follow the comment conventions below when adding code.

#### Comment conventions

Comments in `init.lua` and the `after/` files follow one style:

- Explain *why*, not what the next line already says.
- Use complete sentences: capitalised, ending in a period. Plugin and section titles are short labels without a period.
- Wrap at 100 columns.
- Document functions with LuaLS annotations (`---` description, then `---@param` / `---@return`).
- Put long explanations above the code rather than trailing it. Short trailing comments are fine for a single option.
- Number steps (`1.`, `2.`) only when the order matters.

## Zsh configuration

`zshrc` is a single file that replaces `~/.zshrc`. It sets up Oh My Zsh with Powerlevel10k, fzf-based completion and history, modern CLI replacements, and a few helper functions. Everything that depends on an optional tool is guarded with `command -v`, so a missing tool skips its block instead of breaking the shell.

### Zsh installation

```sh
ln -sf ~/.config/nvim/zshrc ~/.zshrc
ln -sf ~/.config/nvim/p10k.zsh ~/.p10k.zsh
chsh -s "$(command -v zsh)"
exec zsh
```

Install the [requirements](#zsh-requirements) first. `zshrc` sources `~/.p10k.zsh` when it exists, so the prompt looks the same on first launch. Run `p10k configure` to change it.

### Zsh requirements

- `zsh`, [Oh My Zsh](https://ohmyz.sh), and the [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- Oh My Zsh custom plugins: `fzf-tab`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `zsh-completions`
- [`fzf`](https://github.com/junegunn/fzf) and [`zoxide`](https://github.com/ajeetdsouza/zoxide). Both are initialised through a cache (see below).
- Optional: `fd`, `bat`, `eza`, `rg` (previews and aliases), `lazygit`, `kitten` or `chafa` (`icat`), `uv`, `pnpm`
- Optional, for `extract` and `compress`: multithreaded archive tools such as `pigz`, `lbzip2`, `zstd`, `7z`. Each falls back to the standard tool when missing.
- Optional, for the DNS helpers: NetworkManager (`nmcli`), `dnscrypt-proxy`, `dig`, and `sudo`

See [Zsh and shell tools](#zsh-and-shell-tools-dnf-and-git) at the end of this file for the install commands.

### Zsh sections

`zshrc` has no numbering, but it reads top to bottom in this order:

| Part | Contents |
| --- | --- |
| Prompt | Powerlevel10k instant prompt, kept at the very top |
| Environment | `PATH` (`~/.local/bin`, `~/go/bin`, `~/.cargo/bin`), Oh My Zsh path and theme, `EDITOR` / `VISUAL` set to `nvim` |
| History and options | 50,000 entries in `~/.zsh_history`, shared across terminals, duplicates removed, secret-looking commands never written (see below), `AUTO_CD`, `AUTO_PUSHD`, no beep |
| Plugins | `git`, `fzf-tab`, `zsh-autosuggestions` (async), `sudo`, `copypath`, `copyfile`, `zsh-syntax-highlighting`, plus `zsh-completions` on `fpath`. The per-startup `compaudit` scan is skipped. |
| fzf | `fd` as the file source, `bat` and `eza` previews, and the fzf key bindings loaded through `_cache_eval` |
| Aliases | Modern CLI replacements and shortcuts (see below) |
| Completion | Case-insensitive and partial matching, fzf-tab renders the menu, completions and the completion dump (`ZSH_COMPDUMP`) kept in `~/.cache/zsh` instead of `$HOME` |
| Archives | The `extract` and `compress` functions, with tab completion for `compress` |
| Bytecode | `~/.zshrc` and `~/.p10k.zsh` are compiled with `zcompile` whenever they change |
| Tooling | `pnpm` on `PATH`, the DNS mode helpers, the `uv` wrapper, `upall` and `clone` |
| Key bindings | `Alt+j` / `Alt+k` history search |
| zoxide | Initialised last, replacing `cd` |

`_cache_eval` caches the output of slow `eval "$(tool init)"` calls (fzf, zoxide) under `~/.cache/zsh` and regenerates it when the tool's binary changes. This keeps startup fast.

### Aliases and functions

| Name | Description |
| --- | --- |
| `ls`, `ll`, `la`, `lt` | `eza` with icons (`--icons=auto`; `ll` adds git status, `lt` is a two-level tree). Needs `eza`. |
| `cat`, `bcat` | `bat` without a pager. `man` pages also render through `bat`. Needs `bat`. |
| `grep` | Runs on `rg -uuu` whenever rg can give grep's result, including in pipes, and on GNU grep otherwise (see [grep](#grep)). Needs `rg`. |
| `v`, `vim` | `nvim` |
| `lg` | `lazygit` |
| `icat` | Show an image in the terminal through `kitten icat`, or `chafa` as a fallback |
| `sudo` | Defined with a trailing space so aliases still expand after it |
| `dfh`, `duh`, `ports` | `df -h`, a sorted one-level `du -h`, and `ss -tulpn` |
| `reload` | Restart the shell with `exec zsh` |
| `mkcd <dir>` | Create a directory and enter it |
| `cd`, `cdi` | zoxide's jump commands replace `cd` (`--cmd cd`); `cdi` picks a directory interactively |
| `extract <file>...` | Unpack almost any archive type, using the multithreaded tool when it is installed |
| `compress <type> <path> [level]` | Create an archive, e.g. `compress tar.zst mydir -19`. Press `Tab` to list types and levels. |
| `dnsplain` / `portal-mode` | Point `/etc/resolv.conf` at the network's own DHCP DNS, for captive-portal logins |
| `dnsodoh` / `secure-mode` | Switch back to the local `dnscrypt-proxy` (ODoH) resolver and check that it resolves |
| `dnsstatus` | Show the active DNS mode and time a lookup |
| `uv add <pkg>` | Outside any project, first creates a bare `pyproject.toml`, then runs the normal `uv add`. Everything else passes straight through. |
| `uv run <name>` | Runs `<name>.py` when `<name>` is not a file, a command on `PATH` or a project script, so `uv run Q10` runs `Q10.py` |
| `upall` | Runs the `dnf`, `gup`, `pnpm`, `rustup`, `cargo install-update`, `uv tool` and `flatpak` updates in turn and lists any step that failed |
| `clone <repo>` | `git clone`, then `cd` into the result. Takes a URL, `owner/repo`, or a bare name for `github.com/Aniruddhraam/<repo>`; extra arguments go to `git clone`. |

The DNS helpers rewrite `/etc/resolv.conf` with `sudo`. They assume `dnscrypt-proxy` runs in both modes and only the resolver file changes.

### grep

`grep` is a function that translates the grep command line into ripgrep flags. It runs `rg -uuu` (no ignore files; hidden and binary files included, so it searches the same files grep does) whenever rg can produce grep's result, and GNU grep otherwise.

- Flags: `-i -y -v -w -x -c -l -L -n -H -h -o -q -s -a -b -Z -r -R -I -E -F -G -P`, `-e`, `-m`, `-A`/`-B`/`-C`, `-NUM`, their long forms, `--color`, `--include`, `--exclude`, `--exclude-dir` and `--binary-files`. Any other flag uses GNU grep.
- Patterns: basic and `-E` regexes are rewritten into rg syntax, so `\|`, `\(` and `\{` stay operators and bare `|`, `(` and `{` stay literal. Back-references, `[[]`-style brackets, GNU-only escapes and newline-separated pattern lists use GNU grep.
- At the terminal, rg adds smart case and its grouped, line-numbered output. With no file and the terminal as input, it searches the current directory instead of waiting for input.
- Piped or captured output stays plain grep lines with grep's case rules, and rg's "binary file matches" notice goes to stderr, as grep's does.

Scripts never see the function. Use `command grep` for GNU grep at the prompt.

### History filter

A `zshaddhistory` hook drops commands that look like they carry a secret before they reach `~/.zsh_history`: assignments to variables whose names contain `TOKEN`, `SECRET`, `PASSWORD`, `PASSWD`, `API_KEY` or `BW_SESSION`; `--password`, `--token`, `--api-key` and `--secret` flags; `Authorization: Bearer` headers; and values starting with `ghp_`, `gho_`, `github_pat_`, `sk-ant-`, `xoxb-`, `xoxp-` or `AKIA`. The command still runs. Starting a command with a space also keeps it out of history (`HIST_IGNORE_SPACE`).

### Zsh key bindings

| Key | Action |
| --- | --- |
| `Ctrl+R` / `Ctrl+T` / `Alt+C` | fzf history, file and directory search |
| `Alt+j` / `Alt+k` | Down / up through history, matching what is already typed (same as the Neovim mappings) |
| `Tab` | fzf-tab completion menu. `<` and `>` switch completion groups. |

### Zsh customising

- Change the prompt with `p10k configure` or by editing `p10k.zsh` (linked to `~/.p10k.zsh`).
- Add or remove Oh My Zsh plugins in the `plugins=( ... )` array. Keep `fzf-tab` before `zsh-autosuggestions` and `zsh-syntax-highlighting`, since it must load before plugins that wrap ZLE widgets.
- `grep` runs on ripgrep where it can (see [grep](#grep)). Call `command grep` when you need GNU grep.
- Edit the package list in `upall` to match the global `pnpm` packages you keep.
- Cached `tool init` output lives in `~/.cache/zsh`. Delete a file there to force it to regenerate.
- The `PNPM_HOME` block holds an absolute path written by the pnpm installer. Change it if the home directory differs.
- The commented-out options near the top of the file are Oh My Zsh's stock template. The sections after them are headed by `# ====` banners.

## Installing dependencies (Linux)

This section covers every item from [Requirements](#requirements), [Language servers and formatters](#language-servers-and-formatters) and [Zsh requirements](#zsh-requirements). It is written for Fedora. Each tool uses the fastest source available: **native compiled binaries** (Rust, Go, C/C++) from `dnf`, `cargo` or `go install`, and JavaScript tooling from `pnpm`. Where a tool has a compiled replacement for a slower default, that one is used.

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

### Zsh and shell tools (`dnf` and `git`)

Package names below are for Fedora and may differ elsewhere.

```sh
sudo dnf install -y zsh bat eza zoxide chafa \
    pigz lbzip2 zstd lz4 lzop brotli p7zip p7zip-plugins
```

Install Oh My Zsh without letting it overwrite `~/.zshrc`, then clone the theme and plugins into its custom directory:

```sh
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
git clone --depth=1 https://github.com/romkatv/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"
git clone --depth=1 https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone --depth=1 https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
```

`fzf`, `fd` and `rg` come from the [system packages](#system-packages-dnf) above. `uv` and `pnpm` are covered in their own sections. The DNS helpers need `dnscrypt-proxy` configured separately; they only switch `/etc/resolv.conf`.

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
for t in nvim git zsh fzf fd rg bat eza zoxide lazygit magick soffice clangd clang-format \
         rust-analyzer rustfmt gopls gofmt dlv texlab taplo \
         vtsls basedpyright-langserver oxlint oxfmt black jupytext; do
  command -v "$t" >/dev/null && echo "ok      $t" || echo "MISSING $t"
done
```

Then open Neovim and run `:checkhealth` and `:Lazy`. In a new Zsh session, `reload` should start without errors and `ll` should list files with icons.

