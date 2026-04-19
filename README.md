# Dependencies
---
Tmux 3.5+
Neovim 11+
gnu stow
fzf

# Setup
---
1. install GNU stow
2. clone this repo
3. inside the repo run `stow -t ~ .`

And to delete the symlinks run
`stow -t ~ -D .`

# Compiling tmux 3.5 from source on redhat/fedora
---
1. Install build dependencies:
   sudo dnf install -y \
       gcc make pkg-config bison \
       libevent-devel \
       ncurses-devel \
       autoconf automake

   Note: if libevent-devel is not in base repos, try:
   sudo dnf install -y epel-release
   sudo dnf install -y libevent-devel

2. Download tmux source (latest stable — check https://github.com/tmux/tmux/releases):
   cd /tmp
   curl -LO https://github.com/tmux/tmux/releases/download/3.5/tmux-3.5.tar.gz
   tar -xzf tmux-3.5.tar.gz
   cd tmux-3.5

3. Configure and build:
   ./configure --prefix=/usr/local
   make -j$(nproc)

4. Install:
   sudo make install

   This installs to /usr/local/bin/tmux. Verify:
   /usr/local/bin/tmux -V

5. Make sure /usr/local/bin is first in your PATH (it should be already if your
   .personal_zshrc or .zshrc has a PATH prepend). Verify the right tmux is used:
   which tmux
   tmux -V

6. (Optional) If you want the system tmux replaced:
   sudo ln -sf /usr/local/bin/tmux /usr/bin/tmux

# Clipboard Over SSH (Windows → WSL → RHEL)
---
Getting copy-paste to work across the full stack (WezTerm on Windows, tmux and
neovim on a headless RHEL box over SSH) requires several layers to cooperate.
The mechanism is **OSC 52** — an ANSI escape sequence that tells the terminal
emulator to write text directly to the OS clipboard. SSH is transparent to it,
so a sequence emitted by neovim on RHEL travels through both hops and lands in
the Windows clipboard with no X11 or xclip required.

## Tmux version

tmux 3.3+ is required for `allow-passthrough on`, which lets OSC 52 sequences
from inside panes pass through to the outer terminal cleanly. RHEL 8's default
repos only carry tmux 2.7 — compile from source or install from EPEL and verify
the version before assuming the clipboard config will work.

## WezTerm must connect via SSH, not the WSL domain

WezTerm's default WSL domain routes through Microsoft's **ConPTY** layer, which
causes two problems:

1. **OSC 52 is silently stripped** — copies from neovim/tmux never reach the
   Windows clipboard.
2. **XTVERSION responses leak into panes** — tmux 3.3+ queries the outer
   terminal for capabilities on startup. ConPTY mishandles the round-trip,
   causing WezTerm's DCS response (`ESC P > | WezTerm ... ESC \`) to arrive
   after tmux has started routing input to the first pane. The escape sequence
   leaks into the shell, triggering zsh's vi-mode and printing garbage on
   startup.

The fix is to connect to WSL via SSH instead of the WSL domain (see Wezterm
section below). This bypasses ConPTY entirely and both problems disappear.

## tmux.conf settings

```tmux
set -sg allow-passthrough on
set -s set-clipboard on
set -as terminal-features ",xterm*:clipboard"
set -ag terminal-overrides ",xterm*:Ms=\E]52;c%p1%.0s;%p2%s\007"
set -ag terminal-overrides ",screen*:Ms=\E]52;c%p1%.0s;%p2%s\007"
```

The `screen*` override covers the case where the outer tmux (in WSL) changes
`$TERM` to `screen-256color`, which would otherwise break the clipboard chain.

Note: `\007` not `\7` — tmux 3.5's config parser requires 3-digit octal escapes.

`allow-passthrough` and `set-clipboard` are **server options** and must use
`set -s` (or `set -sg`), not `set -g`. Using the wrong scope silently fails.

## neovim clipboard config

nvim 0.10+ has a built-in OSC 52 provider. Configure it explicitly rather than
relying on auto-detection, which breaks inside tmux because `$SSH_TTY` may not
propagate to the tmux environment:

```lua
local osc52 = require('vim.ui.clipboard.osc52')
vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = osc52.copy('+'),
    ['*'] = osc52.copy('*'),
  },
  paste = {
    ['+'] = function()
      return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
    end,
    ['*'] = function()
      return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
    end,
  },
}
vim.opt.clipboard:append({ 'unnamedplus' })
```

Paste uses the internal unnamed register rather than querying WezTerm for the
Windows clipboard. Full OSC 52 paste is unreliable on Windows and causes neovim
to freeze for ~10 seconds waiting for a response that never comes. For pasting
from Windows, use `Ctrl+Shift+V` (WezTerm bracketed paste) instead.

## Paste from Windows into neovim/shell

- `Ctrl+Shift+V` in WezTerm — sends Windows clipboard as bracketed paste through SSH, works everywhere
- `prefix + ]` in tmux — pastes from tmux's own buffer

# tmux-resurrect (session save/restore)
---

tmux-resurrect saves and restores tmux sessions — session names, windows, pane
layouts, working directories, and optionally running programs. It is installed
without TPM directly into the proj space so nothing touches `/home`.

## What is and isn't restored

- Session names, window names, pane count and layout: **yes**
- Working directory per pane: **yes**
- Neovim instances: **yes** — nvim is restarted in the correct directory
- All other processes (shells, compiles, perf jobs, etc.): **no** — panes
  restore to a clean shell in the saved working directory
- Unsaved buffer content, running process state: **never** (nothing can restore these)

## Installation

```bash
# Clone into proj space — nothing goes to /home
git clone https://github.com/tmux-plugins/tmux-resurrect \
    /path/to/$USER/bin/tmux-resurrect

# Create the save directory
mkdir -p /path/to/$USER/bin/tmux-sessions
```

## tmux.conf snippet

Add this block to `.tmux.conf` (already done if using this dotfiles repo):

```tmux
# ── tmux-resurrect ───────────────────────────────────────────────────────────
# Save directory on proj space — keeps /home clean, survives host reboots
set -g @resurrect-dir '/path/to/$USER/bin/tmux-sessions'

# Only restart nvim on restore — everything else drops back to a clean shell
set -g @resurrect-processes 'nvim'

# Keybindings (set before run-shell so the plugin picks them up)
# prefix + Ctrl-s  →  save
# prefix + Ctrl-u  →  restore  (Ctrl-r is reserved for zsh history search)
set -g @resurrect-save    'C-s'
set -g @resurrect-restore 'C-u'

run-shell /path/to/$USER/bin/tmux-resurrect/resurrect.tmux
```

## Usage

| Action | Key |
|---|---|
| Save current sessions | `prefix + Ctrl-s` |
| Restore last saved sessions | `prefix + Ctrl-u` |

Save before planned kills or upgrades. After a crash or reboot, start a fresh
tmux server and press `prefix + Ctrl-u` to restore.

## Updating

```bash
cd /path/to/$USER/bin/tmux-resurrect && git pull
```

## Notes

- Save files are plain text, a few KB each. Resurrect keeps the last 5 saves
  by default; the most recent is always symlinked as `last`.
- The save directory (`tmux-sessions/`) is on the cluster NFS so it is
  accessible from any machine you run tmux on.
- The plugin scripts load once at tmux server start — NFS latency is not a
  practical concern for save/restore operations.

# Wezterm
---
If you're forced to use windows, here's a very basic wezterm config to drop into wsl
Note that WSL likely has to be started first
```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font('Source Code Pro')
config.ssh_domains = {
  {
    name = 'wsl',
    remote_address = '127.0.0.1',
    username = '<your-user>',
  },
}

config.default_domain = 'wsl'

return config
```
