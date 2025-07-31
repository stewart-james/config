-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_prog = { "pwsh.exe", "-NoLogo" }
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.scrollback_lines = 7000
config.initial_cols = 120
config.initial_rows = 28

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 12
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "NONE | RESIZE"
config.cell_width = 1.0
config.default_cursor_style = "SteadyBlock"


config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- windows 11 stuff --
config.win32_acrylic_accent_color = "rgb(94, 64, 157)"
config.webgpu_power_preference = "HighPerformance"
config.front_end = "OpenGL"
config.prefer_egl = true
config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

local act = wezterm.action
config.leader = { key = 'a', mods = 'CTRL' }
config.keys = {

	{ key = 't', mods = 'LEADER', action = wezterm.action.SpawnTab('CurrentPaneDomain'), },
	{ key = 'q', mods = 'LEADER', action = wezterm.action.CloseCurrentTab { confirm = false } },

	{ key = "1", mods = "CTRL",   action = act.ActivateTab(0) },
	{ key = "2", mods = "CTRL",   action = act.ActivateTab(1) },
	{ key = "3", mods = "CTRL",   action = act.ActivateTab(2) },
	{ key = "4", mods = "CTRL",   action = act.ActivateTab(4) },
	{ key = "5", mods = "CTRL",   action = act.ActivateTab(4) },

	{ key = "v", mods = "LEADER", action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = "s", mods = "LEADER", action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

	{ key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Right"), },
	{ key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Up"), },
	{ key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Down"), },
	{ key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Left"), },
}


return config
