-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
-- Font
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 13.0

-- Scroll
config.scrollback_lines = 100000

-- Tab
config.hide_tab_bar_if_only_one_tab = true

-- Color scheme
config.color_scheme = 'nord'

-- and finally, return the configuration to wezterm
return config
