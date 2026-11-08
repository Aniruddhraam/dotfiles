# Performance upgrades

Performance changes for this setup on the Fedora 45 laptop (Core Ultra 9 185H with 22 threads, 30 GiB RAM, RTX 4070 Laptop and Arc iGPU, btrfs on LUKS2), as of 2026-11-07. The aim is to swap runtime-based or single-threaded tools for native, parallel ones without changing how anything is used, and to keep each one current through `upall`.

## Applied

| Change | Replaces | Where | Kept current by |
| --- | --- | --- | --- |
| TypeScript 7's native language server, started as `tsgo` | vtsls on TypeScript 6's tsserver (Node) | `init.lua`; `_upall_tsgo_link` links the native binary into `~/.local/bin/tsgo` | `pnpm update -g`, then `_upall_tsgo_link` |
| ty (Rust) | basedpyright (Node) | `init.lua` | `uv tool upgrade --all` |
| `ruff format` (Rust), and black only in projects whose pyproject.toml has `[tool.black]` | black for every Python file (about 0.2 s to start, 0.8 s on a 3,100-line file, against 14 ms for ruff) | `init.lua` (`python_formatter`) | `uv tool upgrade --all` |
| antidote static plugin file and fast-syntax-highlighting | Oh My Zsh's loader and zsh-syntax-highlighting | `zshrc`, `zsh_plugins.txt` | `antidote update` |
| `compinit -C` unless an `fpath` directory changed | A full `fpath` scan on every start | `zshrc` | Nothing to update |
| Go tools built with `GOAMD64=v3` (AVX2, BMI2, FMA) | Baseline x86-64 builds of gopls, lazygit, dlv and gup | `upall` | `GOAMD64=v3 gup update` |
| `ffmpeg` wrapper on NVENC or Quick Sync | Software libx264, libx265 and AV1 encoders | `zshrc` | `dnf upgrade` (RPM Fusion ffmpeg) |
| `make` and `cmake --build` on every thread, Ninja for CMake | Serial `make`, Makefile generator | `zshrc` | `dnf upgrade` |
| ccache for C, C++ and CUDA, sccache for Rust | Uncached compiles | `zshrc` (CMake launchers), `~/.cargo/config.toml` | `dnf upgrade` |
| mold through `COMPILER_PATH` and `-fuse-ld=mold` in Cargo | GNU ld and rust-lld | `zshrc`, `~/.cargo/config.toml` | `dnf upgrade` |
| git `core.fsmonitor`, `core.untrackedCache`, `feature.manyFiles`, `fetch.writeCommitGraph` | Full worktree scans | `~/.gitconfig` (outside this repo) | `dnf upgrade` (git) |
| btrfs `noatime` on `/` and `/home` | `relatime` | `/etc/fstab` | Nothing to update |
| dm-crypt without read and write workqueues, discards kept | Default dm-crypt queues | LUKS2 header (persistent flags) | Nothing to update |

`zsh -i -c exit` went from about 220 ms to 80–100 ms on this machine after the antidote and `compinit` changes.

Notes:

- TypeScript 7.0's server has no refactor code actions yet (extract, move to file, convert export, infer return type).
- The system `ld` stays GNU ld through `alternatives`. `akmod-nvidia` builds the NVIDIA kernel module with plain `ld`, and mold isn't built for kernel and module linking, so mold is only the default for links that `gcc`, `clang`, `nvcc` and Cargo run.
- `core.fsmonitor` starts a small inotify daemon per repository the first time `git status` runs there. Turn it off for one repository with `git config core.fsmonitor false`.

### System changes (outside this repo)

These need root and were applied once. To redo them on another machine, adjust the LUKS mapping name:

```sh
# btrfs: add noatime after subvol=... on the / and /home lines, then remount
sudo sed -E -i '/^[^#]*[[:space:]](\/|\/home)[[:space:]]+btrfs[[:space:]]/{/noatime/!s/(subvol=[^,[:space:]]+)/\1,noatime/}' /etc/fstab
sudo systemctl daemon-reload
sudo mount -o remount,noatime / && sudo mount -o remount,noatime /home

# dm-crypt: keep --allow-discards if discards are on now (lsblk -D shows a non-zero DISC-MAX),
# because refresh resets every flag it isn't given
sudo cryptsetup refresh --perf-no_read_workqueue --perf-no_write_workqueue --allow-discards \
  --persistent luks-a5653737-44d8-4609-bd92-244b31b6022d
sudo dmsetup table luks-a5653737-44d8-4609-bd92-244b31b6022d | grep -oE 'allow_discards|no_(read|write)_workqueue'

# git
git config --global core.fsmonitor true
git config --global core.untrackedCache true
git config --global feature.manyFiles true
git config --global fetch.writeCommitGraph true
```

To undo the dm-crypt flags, run `sudo cryptsetup refresh --allow-discards --persistent <mapping>`. Undo `noatime` by restoring the `/etc/fstab.bak-*` copy.

## Suggested next

Ordered by value for the effort.

| Change | Replaces | How | Watch for |
| --- | --- | --- | --- |
| `ZSH_AUTOSUGGEST_MANUAL_REBIND=1` and `ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20` | zsh-autosuggestions rewrapping every widget before each prompt | Set both next to `ZSH_AUTOSUGGEST_USE_ASYNC`, and call `_zsh_autosuggest_bind_widgets` at the end of `zshrc`, after fzf's widgets exist | Widgets defined after that call are not wrapped |
| Neovim plugins and parsers in `upall` | Updating them by hand in `:Lazy` | `nvim --headless '+Lazy! sync' +qa`, then `nvim --headless -c 'lua require("nvim-treesitter").update():wait(300000)' -c qa` | Rewrites `lazy-lock.json` |
| dust | `du -h --max-depth=1 \| sort -h` (`duh`) | `cargo install --locked du-dust`, then `alias duh='dust -d 1'` | Output format differs from `du` |
| rust-parallel | GNU parallel (Perl) for simple fan-out | `cargo install --locked rust-parallel` | Covers `cmd ::: a b c`; keep GNU parallel for its other options |
| zram on zstd | `lzo-rle` | `compression-algorithm = zstd` under `[zram0]` in `/etc/systemd/zram-generator.conf`, applied on reboot | Low priority: swap use is near zero with 30 GiB RAM |
| Built-in cmdline and message UI (`require("vim._core.ui2").enable({})`) | noice.nvim | Neovim 0.12 ships it as experimental | The custom LSP progress view is built on noice |
| ccache for direct `nvcc` calls | Uncached `nvcc` in hand-written Makefiles | `make NVCC='ccache nvcc'` for Makefiles that use `$(NVCC)` | CMake projects already use the CUDA launcher |
| `git maintenance start` | `git gc --auto` running in the middle of commands | Run once inside each repository used daily | Adds systemd user timers per repository |
| google-java-format's native Linux binary | The JAR (JVM start on every format) | Download `google-java-format_linux-x86-64` from its releases into `~/.local/bin`, with an `upall` step like `_upall_duckdb` | Only matters once Java work starts |
| `cargo uninstall starship` | An unused prompt build | p10k is the prompt and nothing references starship | `cargo install-update -a` stops rebuilding it |

## Not recommended here

- **mold as the system `ld` through `alternatives`:** kernel-module builds (`akmod-nvidia`) would link with it.
- **CachyOS kernels or sched_ext schedulers:** they need COPRs and interact with the NVIDIA akmods and the CUDA repository, and they mainly help under heavy mixed load.
- **uutils coreutils:** it isn't uniformly faster than GNU coreutils.
