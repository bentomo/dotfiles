# Dependencies
---
Tmux 3.3+
Neovim 11+
gnu stow

# Setup
---
1. install GNU stow
2. clone this repo
3. inside the repo run `stow -t ~ .`

And to delete the symlinks run
`stow -t ~ -D .`

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
