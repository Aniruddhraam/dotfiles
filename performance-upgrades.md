# Performance upgrades

Performance changes for this setup on the Fedora 45 laptop (Core Ultra 9 185H with 22 threads, 30 GiB RAM, RTX 4070 Laptop and Arc iGPU, btrfs on LUKS2), as of 2026-11-13. The aim is to swap runtime-based or single-threaded tools for native, parallel ones without changing how anything is used, and to keep each one current through `upall`.

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
| git `core.fsmonitor`, `core.untrackedCache`, `feature.manyFiles`, `fetch.writeCommitGraph` | Full worktree scans | `~/.gitconfig` and `~/.config/git/no-fsmonitor.gitconfig` (outside this repo) | `dnf upgrade` (git) |
| btrfs `noatime` on `/` and `/home` | `relatime` | `/etc/fstab` | Nothing to update |
| dm-crypt without read and write workqueues, discards kept | Default dm-crypt queues | LUKS2 header (persistent flags) | Nothing to update |

`zsh -i -c exit` went from about 220 ms to 80–100 ms on this machine after the antidote and `compinit` changes.

Notes:

- TypeScript 7.0's server has no refactor code actions yet (extract, move to file, convert export, infer return type).
- The system `ld` stays GNU ld through `alternatives`. `akmod-nvidia` builds the NVIDIA kernel module with plain `ld`, and mold isn't built for kernel and module linking, so mold is only the default for links that `gcc`, `clang`, `nvcc` and Cargo run.
- `core.fsmonitor` starts a small inotify daemon per repository the first time `git status` runs there, and the daemon keeps running. lazy.nvim and antidote run git in every plugin checkout when they check for updates, which on 2026-11-11 had left 46 daemons running (about 500 threads and 250 MB), 45 of them in plugin checkouts. `includeIf` rules in `~/.gitconfig` now load `~/.config/git/no-fsmonitor.gitconfig` (`core.fsmonitor = false`) for `~/.local/share/nvim/lazy/`, `~/.cache/antidote/` and `~/.antidote/`, so only repositories you work in get a daemon. Turn it off for one more repository with `git config core.fsmonitor false`, and stop its running daemon with `git fsmonitor--daemon stop`.

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

# git: no fsmonitor daemons in plugin checkouts
mkdir -p ~/.config/git
printf '[core]\n\tfsmonitor = false\n' > ~/.config/git/no-fsmonitor.gitconfig
git config --global 'includeIf.gitdir:~/.local/share/nvim/lazy/.path' '~/.config/git/no-fsmonitor.gitconfig'
git config --global 'includeIf.gitdir:~/.cache/antidote/.path' '~/.config/git/no-fsmonitor.gitconfig'
git config --global 'includeIf.gitdir:~/.antidote/.path' '~/.config/git/no-fsmonitor.gitconfig'
```

To undo the dm-crypt flags, run `sudo cryptsetup refresh --allow-discards --persistent <mapping>`. Undo `noatime` by restoring the `/etc/fstab.bak-*` copy.

## Network

These changes were applied between 2026-11-04 and 2026-11-11, all outside this repo (root files and NetworkManager profiles). The numbers come from short tests in those sessions, so treat them as rough.

| Change | Replaces | Where | Measured effect |
| --- | --- | --- | --- |
| TCP congestion control BBR | CUBIC, the kernel default | `/etc/sysctl.d/90-congested-wifi.conf`, `/etc/modules-load.d/tcp-bbr.conf` | Campus Wi-Fi uploads (4 × 4 MB each way): about the same median (CUBIC 12.6, BBR 12.1 Mbit/s) but steadier (BBR 11.2–12.7, CUBIC 8.6–15.4 Mbit/s) |
| `tcp_slow_start_after_idle = 0` | The congestion window shrinking after every idle gap | `/etc/sysctl.d/90-congested-wifi.conf` | Not measured on its own; helps bursty traffic such as web browsing |
| `tcp_wmem` max 32 MB, matching `tcp_rmem` | The 4 MB kernel default | `/etc/sysctl.d/91-tcp-buffers.conf` | None beyond noise, and the send buffer never limited a connection. It's headroom for single uploads to distant, fast servers |
| Wi-Fi power save off on AC, on every network | The driver default (on) | `/usr/local/sbin/wifi-powersave-ac`, `wifi-powersave-ac.service`, `/etc/udev/rules.d/90-wifi-powersave-ac.rules`, `/etc/NetworkManager/dispatcher.d/90-wifi-powersave-ac` | On campus (2026-11-04, then a per-profile setting): ping to 8.8.8.8 went from ~190 to ~82 ms on average, and spikes from ~1.1 to ~0.5 s. On battery each profile keeps its own setting |
| Campus profile: `powersave 2`, `band a`, `metered yes` | Power save on, 2.4 GHz allowed, unmetered | NetworkManager profile `AMRITA-BLR-Connect`, my university's enterprise Wi-Fi (WPA-Enterprise, 802.1X with PEAP and MSCHAPv2) | Stays on 5 GHz and keeps power save off on battery too. Metered tells apps to hold back automatic downloads |
| IPv6 off on the ACT profiles | ACT's IPv6, which has a default route but no address, so every dual-stack connection waited for IPv6 to time out | NetworkManager profiles `Wired connection 1`, `ACTFIBERNET_5G` | New connection to google.com: 218 → 18 ms |
| dnscrypt-proxy on direct Cloudflare DoH, `cache_min_ttl = 1800` | ODoH through a randomly picked relay (often one in Germany), `cache_min_ttl = 2400` | `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` (backup `dnscrypt-proxy.toml.bak-odoh-2026-11-06`) | Uncached lookups went from ~165 ms to 7–39 ms. CDN sites now answer from servers 2–47 ms away instead of 109–177 ms, and the github.com homepage loads in 144 ms instead of 798 ms. The trade-off is that Cloudflare sees your IP address |

**BBR and CUBIC.** Both are TCP congestion-control algorithms, which decide how fast this laptop sends data. CUBIC, the Linux default, keeps speeding up until a packet is lost, then cuts its rate by about 30%. On Wi-Fi, packets are also lost to radio interference, not only to congestion, so CUBIC slows down when it doesn't need to. BBR measures the path's bandwidth and round-trip time and paces packets at that rate, so a random loss doesn't make it back off. It only changes what this laptop sends (uploads and requests). Downloads follow the server's algorithm. The qdisc stays `fq_codel`: BBR paces on its own, and the Wi-Fi stack (mac80211) has its own fq_codel.

**Home wired connection.** At home on ACT, the laptop uses a Realtek RTL8156B USB 2.5 GbE adapter (`enp0s13f0u4`). It links at 1 Gbit/s because the router port is gigabit, and measured ~650 Mbit/s each way with 6 ms average ping under load. NetworkManager prefers it (route metric 100) over Wi-Fi (600), which stays connected as a fallback.

Left as is:

- **Ethernet adapter tuning** (ring buffers, offloads, interrupt coalescing, jumbo frames): 0 errors and no bufferbloat, so there's nothing to gain.
- **Bufferbloat and QoS on home Wi-Fi** (Excitel: ping under load 16 ms average, 67 ms max): only the router can fix these, for example with SQM/cake on your own router.

Check the current state:

```sh
sysctl net.ipv4.tcp_congestion_control net.ipv4.tcp_slow_start_after_idle net.ipv4.tcp_wmem
iw dev wlo1 get power_save
nmcli -g ipv6.method con show "Wired connection 1"
rg '^(server_names|doh_servers|odoh_servers|cache_min_ttl)' /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```

Redo on another machine:

```sh
# BBR, no slow start after idle, 32 MB max send buffer
printf 'net.ipv4.tcp_congestion_control = bbr\nnet.ipv4.tcp_slow_start_after_idle = 0\n' | sudo tee /etc/sysctl.d/90-congested-wifi.conf
echo 'net.ipv4.tcp_wmem = 4096 16384 33554432' | sudo tee /etc/sysctl.d/91-tcp-buffers.conf
echo tcp_bbr | sudo tee /etc/modules-load.d/tcp-bbr.conf
sudo modprobe tcp_bbr && sudo sysctl --system

# Campus profile, and IPv6 off where the network's IPv6 is broken.
# AMRITA-BLR-Connect is my university's enterprise Wi-Fi (802.1X, PEAP/MSCHAPv2);
# these settings only tune it, the login stays in the existing profile.
nmcli con mod AMRITA-BLR-Connect 802-11-wireless.powersave 2 802-11-wireless.band a connection.metered yes
nmcli con mod "Wired connection 1" ipv6.method disabled
nmcli con mod ACTFIBERNET_5G ipv6.method disabled

# DNS: in /etc/dnscrypt-proxy/dnscrypt-proxy.toml set server_names = ['cloudflare'],
# doh_servers = true, odoh_servers = false, cache_min_ttl = 1800, comment out the ODoH
# route under [anonymized_dns], then: sudo systemctl restart dnscrypt-proxy
```

To undo them: delete the two `sysctl.d` files and `tcp-bbr.conf` and reboot. Set `ipv6.method auto` on the two ACT profiles. Copy the dnscrypt backup back and restart dnscrypt-proxy. Delete the four power-save files listed above.

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
