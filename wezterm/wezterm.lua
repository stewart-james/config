local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- ─────────────────────────────────────────────────────────────────────────────
-- Leader key: CTRL+q  (press, release, then follow-up key within timeout)
-- Chosen to avoid conflicts with GlazeWM (Alt-based) and Neovim (Ctrl+w etc.)
-- ─────────────────────────────────────────────────────────────────────────────
config.leader = { key = 'q', mods = 'ALT', timeout_milliseconds = 1500 }

-- ─────────────────────────────────────────────────────────────────────────────
-- Catppuccin Mocha
-- ─────────────────────────────────────────────────────────────────────────────
config.colors = {
  foreground    = '#cdd6f4',
  background    = '#1e1e2e',
  cursor_bg     = '#f5e0dc',
  cursor_border = '#f5e0dc',
  cursor_fg     = '#1e1e2e',
  selection_bg  = '#585b70',
  selection_fg  = '#cdd6f4',

  -- 16-color palette
  ansi = {
    '#45475a', -- black
    '#f38ba8', -- red
    '#a6e3a1', -- green
    '#f9e2af', -- yellow
    '#89b4fa', -- blue
    '#cba6f7', -- magenta
    '#94e2d5', -- cyan
    '#bac2de', -- white
  },
  brights = {
    '#585b70', -- bright black
    '#f38ba8', -- bright red
    '#a6e3a1', -- bright green
    '#f9e2af', -- bright yellow
    '#89b4fa', -- bright blue
    '#cba6f7', -- bright magenta
    '#94e2d5', -- bright cyan
    '#a6adc8', -- bright white
  },

  -- Tab bar colors (used even when tab bar is hidden, keeps internal state clean)
  tab_bar = {
    background = '#181825',
    active_tab = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#181825',
      fg_color = '#585b70',
    },
    inactive_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
    },
    new_tab = {
      bg_color = '#181825',
      fg_color = '#585b70',
    },
    new_tab_hover = {
      bg_color = '#313244',
      fg_color = '#cdd6f4',
    },
  },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- Tab bar
-- ─────────────────────────────────────────────────────────────────────────────
config.enable_tab_bar          = true
config.use_fancy_tab_bar       = false
config.tab_bar_at_bottom       = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 60

-- Powerline separators (requires Nerd Font)
local SOLID_LEFT  = '\u{e0b2}'
local SOLID_RIGHT = '\u{e0b0}'

local TAB = {
  active_bg   = '#313244',
  active_fg   = '#cdd6f4',
  active_num  = '#cba6f7',
  inactive_bg = '#1e1e2e',
  inactive_fg = '#6c7086',
  bar_bg      = '#181825',
}

wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
  local title = (tab.tab_title and #tab.tab_title > 0)
    and tab.tab_title
    or  tab.active_pane.title

  -- Pad to min width, trim to max
  local MIN_WIDTH = 12
  local budget = max_width - 6
  if #title > budget then
    title = wezterm.truncate_right(title, budget) .. '…'
  elseif #title < MIN_WIDTH then
    title = title .. string.rep(' ', MIN_WIDTH - #title)
  end

  local idx = tostring(tab.tab_index + 1)

  if tab.is_active then
    return {
      { Background = { Color = TAB.active_bg  } },
      { Foreground = { Color = TAB.bar_bg     } },
      { Text = SOLID_RIGHT                      },
      { Foreground = { Color = TAB.active_num } },
      { Attribute = { Intensity = 'Bold' }      },
      { Text = ' ' .. idx .. ' '               },
      { Foreground = { Color = TAB.active_fg  } },
      { Attribute = { Intensity = 'Normal' }    },
      { Text = title .. ' '                    },
      { Background = { Color = TAB.bar_bg    } },
      { Foreground = { Color = TAB.active_bg  } },
      { Text = SOLID_RIGHT                      },
    }
  end

  local bg = TAB.inactive_bg
  local fg = hover and '#cdd6f4' or TAB.inactive_fg
  return {
    { Background = { Color = bg         } },
    { Foreground = { Color = TAB.bar_bg } },
    { Text = SOLID_RIGHT                  },
    { Foreground = { Color = fg         } },
    { Text = ' ' .. idx .. ' ' .. title .. ' ' },
    { Background = { Color = TAB.bar_bg } },
    { Foreground = { Color = bg         } },
    { Text = SOLID_RIGHT                  },
  }
end)

-- Left status: mode indicator (Neovim when active, WezTerm otherwise)
local WEZTERM_MODES = {
  leader      = { bg = '#cba6f7', label = 'LEADER' },
  copy_mode   = { bg = '#f9e2af', label = 'COPY'   },
  search_mode = { bg = '#89b4fa', label = 'SEARCH' },
}

local NVIM_MODES = {
  n       = { bg = '#89b4fa', label = 'NORMAL'  },
  i       = { bg = '#a6e3a1', label = 'INSERT'  },
  v       = { bg = '#cba6f7', label = 'VISUAL'  },
  V       = { bg = '#cba6f7', label = 'V-LINE'  },
  ['\22'] = { bg = '#cba6f7', label = 'V-BLOCK' },
  c       = { bg = '#fab387', label = 'COMMAND' },
  R       = { bg = '#f38ba8', label = 'REPLACE' },
  t       = { bg = '#94e2d5', label = 'TERMINAL'},
  s       = { bg = '#f9e2af', label = 'SELECT'  },
  no      = { bg = '#89b4fa', label = 'PENDING' },
}

wezterm.on('update-right-status', function(window, pane)
  local m

  -- WezTerm modes take priority (leader, copy, search)
  if window:leader_is_active() then
    m = WEZTERM_MODES.leader
  else
    local kt = window:active_key_table()
    m = kt and WEZTERM_MODES[kt]
  end

  -- Fall back to Neovim mode if nvim is running in this pane
  if not m then
    local nvim_mode = pane:get_user_vars().NVIM_MODE
    if nvim_mode and nvim_mode ~= '' then
      m = NVIM_MODES[nvim_mode] or { bg = '#585b70', label = nvim_mode:upper() }
    end
  end

  -- Default: terminal insert
  if not m then
    m = { bg = '#a6e3a1', label = 'INSERT' }
  end

  window:set_left_status(wezterm.format({
    { Background = { Color = m.bg      } },
    { Foreground = { Color = '#1e1e2e' } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = '   ' .. m.label .. '  '  },
    { Background = { Color = '#181825' } },
    { Foreground = { Color = m.bg      } },
    { Text = SOLID_RIGHT               },
  }))
  window:set_right_status('')
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Toggle bottom pane to 30% height (LEADER + t)
-- Only acts when there are exactly 2 panes in a top/bottom split.
-- Pressing again restores the original heights.
-- ─────────────────────────────────────────────────────────────────────────────
local bottom_pane_state = {}

wezterm.on('toggle-bottom-30', function(window, _)
  local tab   = window:active_tab()
  local panes = tab:panes_with_info()

  if #panes ~= 2 then return end

  -- Expect one pane at row 0 (top) and one below it (bottom)
  local top_info, bot_info
  for _, info in ipairs(panes) do
    if info.top == 0 then top_info = info
    else                  bot_info = info
    end
  end
  if not top_info or not bot_info then return end

  local tab_id = tab:tab_id()
  local total  = top_info.height + bot_info.height

  if bottom_pane_state[tab_id] then
    -- Restore saved height
    local diff = bottom_pane_state[tab_id] - bot_info.height
    if diff ~= 0 then
      local dir = diff > 0 and 'Up' or 'Down'
      window:perform_action(act.AdjustPaneSize { dir, math.abs(diff) }, bot_info.pane)
    end
    bottom_pane_state[tab_id] = nil
  else
    -- Save current height and resize bottom pane to 30%
    bottom_pane_state[tab_id] = bot_info.height
    local target = math.floor(total * 0.20)
    local diff   = target - bot_info.height
    if diff ~= 0 then
      local dir = diff > 0 and 'Up' or 'Down'
      window:perform_action(act.AdjustPaneSize { dir, math.abs(diff) }, bot_info.pane)
    end
  end
end)


-- ─────────────────────────────────────────────────────────────────────────────
-- Window
-- ─────────────────────────────────────────────────────────────────────────────
-- NONE removes the title bar; RESIZE keeps only the resize border.
-- Use RESIZE so GlazeWM can still grab the window edges.
config.window_decorations = 'RESIZE'

config.window_padding = {
  left   = 8,
  right  = 8,
  top    = 8,
  bottom = 8,
}

config.window_background_opacity = 1.0
config.text_background_opacity   = 1.0

-- ─────────────────────────────────────────────────────────────────────────────
-- Font
-- ─────────────────────────────────────────────────────────────────────────────
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 12.0

config.window_frame = {
  font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' }),
  font_size = 13.0,
  border_left_width = '0cell',
  border_right_width = '0cell',
  border_bottom_height = '0cell',
  border_top_height = '0cell',
}
config.line_height = 1.1

-- ─────────────────────────────────────────────────────────────────────────────
-- Shell
-- ─────────────────────────────────────────────────────────────────────────────
config.default_prog = { 'C:/Program Files/PowerShell/7/pwsh.exe', '-NoLogo' }

-- ─────────────────────────────────────────────────────────────────────────────
-- Misc
-- ─────────────────────────────────────────────────────────────────────────────
config.scrollback_lines         = 10000
config.enable_scroll_bar        = false
config.audible_bell             = 'Disabled'
config.visual_bell              = { fade_in_duration_ms = 75, fade_out_duration_ms = 75, target = 'CursorColor' }
config.default_cursor_style     = 'BlinkingBar'
config.cursor_blink_rate        = 500
config.automatically_reload_config = true
config.status_update_interval = 100

-- ─────────────────────────────────────────────────────────────────────────────
-- Keybindings  (all behind LEADER = CTRL+b)
--
-- Reference — what NOT to use:
--   GlazeWM  : Alt+<anything>, Alt+Shift+<anything>
--   Neovim   : Ctrl+w, Ctrl+[, Ctrl+c, Ctrl+d/u, Ctrl+f/b (page scroll),
--              Ctrl+o/i, Ctrl+r, Ctrl+n/p, Ctrl+space, Ctrl+g, Ctrl+l,
--              Ctrl+z, Ctrl+x, Ctrl+a, Ctrl+e, Ctrl+s
--
-- All bindings below use LEADER so they are completely isolated.
-- ─────────────────────────────────────────────────────────────────────────────
config.keys = {

  -- ── Tabs ──────────────────────────────────────────────────────────────────
  -- New tab
  { key = 'c',     mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  -- Close current tab (with confirmation)
  { key = 'X',     mods = 'LEADER', action = act.CloseCurrentTab { confirm = false } },
  -- Next / previous tab
  { key = 'n',     mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p',     mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  -- Jump to tab by index (0-based internally, 1-based for the user)
  { key = '1',     mods = 'LEADER', action = act.ActivateTab(0) },
  { key = '2',     mods = 'LEADER', action = act.ActivateTab(1) },
  { key = '3',     mods = 'LEADER', action = act.ActivateTab(2) },
  { key = '4',     mods = 'LEADER', action = act.ActivateTab(3) },
  { key = '5',     mods = 'LEADER', action = act.ActivateTab(4) },
  { key = '6',     mods = 'LEADER', action = act.ActivateTab(5) },
  { key = '7',     mods = 'LEADER', action = act.ActivateTab(6) },
  { key = '8',     mods = 'LEADER', action = act.ActivateTab(7) },
  { key = '9',     mods = 'LEADER', action = act.ActivateTab(8) },
  -- Rename tab
  {
    key  = 'r',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Rename tab:',
      action = wezterm.action_callback(function(window, _, line)
        if line and #line > 0 then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- ── Pane splitting ────────────────────────────────────────────────────────
  -- Split right  (vertical divider)
  { key = 'v',    mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  -- Split below  (horizontal divider)
  { key = 's',    mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

  -- ── Pane navigation ───────────────────────────────────────────────────────
  { key = 'h',    mods = 'LEADER', action = act.ActivatePaneDirection 'Left'  },
  { key = 'j',    mods = 'LEADER', action = act.ActivatePaneDirection 'Down'  },
  { key = 'k',    mods = 'LEADER', action = act.ActivatePaneDirection 'Up'    },
  { key = 'l',    mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- ── Pane swapping / picking ───────────────────────────────────────────────
  -- Rotate all panes clockwise / counter-clockwise
  { key = 'L',    mods = 'LEADER', action = act.RotatePanes 'Clockwise' },
  { key = 'H',    mods = 'LEADER', action = act.RotatePanes 'CounterClockwise' },
  -- Visual pane picker (shows overlay with pane labels to jump to)
  { key = 'J',    mods = 'LEADER', action = act.PaneSelect { alphabet = '1234567890', mode = 'Activate' } },
  -- Visual pane picker in swap mode (move active pane to selected position)
  { key = 'K',    mods = 'LEADER', action = act.PaneSelect { alphabet = '1234567890', mode = 'SwapWithActive' } },

  -- ── Pane resizing ─────────────────────────────────────────────────────────
  { key = 'LeftArrow',  mods = 'LEADER', action = act.AdjustPaneSize { 'Left',  5 } },
  { key = 'DownArrow',  mods = 'LEADER', action = act.AdjustPaneSize { 'Down',  5 } },
  { key = 'UpArrow',    mods = 'LEADER', action = act.AdjustPaneSize { 'Up',    5 } },
  { key = 'RightArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },

  -- ── Pane management ───────────────────────────────────────────────────────
  -- Close current pane (with confirmation)
  { key = 'x',    mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
  -- Zoom / unzoom pane (temporarily fullscreen within window)
  { key = 'z',    mods = 'LEADER', action = act.TogglePaneZoomState },
  -- Rotate panes
  { key = 'o',    mods = 'LEADER', action = act.RotatePanes 'Clockwise' },
  { key = 'O',    mods = 'LEADER', action = act.RotatePanes 'CounterClockwise' },

  -- ── Scrollback ────────────────────────────────────────────────────────────
  { key = '[',    mods = 'LEADER', action = act.ActivateCopyMode },
  { key = ']',    mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

  -- ── Layout helpers ────────────────────────────────────────────────────────
  -- Toggle bottom pane to 30% / restore original height
  { key = 't', mods = 'LEADER', action = act.EmitEvent 'toggle-bottom-30' },

  -- ── Misc ──────────────────────────────────────────────────────────────────
  -- Reload config
  { key = 'R',    mods = 'LEADER', action = act.ReloadConfiguration },
  -- Show debug overlay
  { key = 'd',    mods = 'LEADER', action = act.ShowDebugOverlay },
}

return config
