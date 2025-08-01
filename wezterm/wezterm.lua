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
config.leader = { key = 'q', mods = 'ALT' }
config.keys = {

	{ key = 't', mods = 'LEADER', action = wezterm.action.SpawnTab('CurrentPaneDomain'), },
	{ key = 'q', mods = 'LEADER', action = wezterm.action.CloseCurrentTab { confirm = false } },

	{ key = "1", mods = "LEADER",   action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER",   action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER",   action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER",   action = act.ActivateTab(4) },
	{ key = "5", mods = "LEADER",   action = act.ActivateTab(4) },

	{ key = "v", mods = "LEADER", action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{ key = "s", mods = "LEADER", action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

	{ key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Right"), },
	{ key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Up"), },
	{ key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Down"), },
	{ key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection("Left"), },

	{ key = 'UpArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { "Up", 5 } },
	{ key = 'DownArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { "Down", 5 } },
	{ key = 'LeftArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { "Left", 5 } },
	{ key = 'RightArrow', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { "Right", 5 } },

	{
		key = 'A',
		mods = 'CTRL', -- Use CTRL for Ctrl+A
		action = wezterm.action_callback(function(window, pane)
			local dims = pane:get_dimensions()
			local txt = pane:get_text_from_region(0, dims.scrollback_top, 0, dims.scrollback_top + dims.scrollback_rows)
			window:copy_to_clipboard(txt:match('^%s*(.-)%s*$')) -- Trim leading and trailing whitespace
		end)
	},
}


return config
