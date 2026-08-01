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
    local tmp = os.getenv('TEMP') or os.getenv('TMP') or 'C:\\Temp'
    local path = tmp .. '\\wezterm_nvim_' .. tostring(pane:pane_id()) .. '.mode'
    local f = io.open(path, 'r')
    if f then
      local mode_char = f:read('*l')
      f:close()
      if mode_char and mode_char ~= '' then
        m = NVIM_MODES[mode_char] or { bg = '#585b70', label = mode_char:upper() }
      end
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
  local ws_bg    = '#94e2d5'
  local clock_bg = '#b4befe'
  local ws_name  = window:active_workspace()
  window:set_right_status(wezterm.format({
    -- Workspace pill
    { Background = { Color = '#181825' } },
    { Foreground = { Color = ws_bg     } },
    { Text = SOLID_LEFT                  },
    { Background = { Color = ws_bg     } },
    { Foreground = { Color = '#1e1e2e' } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = '  \u{f121} ' .. ws_name .. '  ' },
    -- Clock pill
    { Background = { Color = ws_bg     } },
    { Foreground = { Color = clock_bg  } },
    { Text = SOLID_LEFT                  },
    { Background = { Color = clock_bg  } },
    { Foreground = { Color = '#1e1e2e' } },
    { Text = '  \u{f017} ' .. wezterm.time.now():format('%H:%M') .. '   ' },
  }))
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Machine-local settings: repo scan dirs and Azure DevOps org/project live
-- in C:\projects\settings.json rather than this file, since this config is
-- version-controlled (D:\config, pushed to GitHub) and those values are
-- specific to this machine / this user's ADO setup. See
-- wezterm/settings.example.json in this repo for the expected shape and
-- a template to copy to C:\projects\settings.json on a new machine.
-- Missing file / bad JSON degrades gracefully (empty scan list, ADO
-- features report a clear error) rather than breaking config load.
-- ─────────────────────────────────────────────────────────────────────────────
local function load_settings()
  local path = 'C:\\projects\\settings.json'
  local f = io.open(path, 'r')
  if not f then
    wezterm.log_warn('wezterm: could not open ' .. path .. ' (repo scanning / Azure DevOps features will be empty until it exists)')
    return {}
  end
  local content = f:read('*a')
  f:close()

  local data = wezterm.json_parse(content)
  if not data then
    wezterm.log_warn('wezterm: failed to parse ' .. path .. ' as JSON')
    return {}
  end
  return data
end

local settings = load_settings()

-- ─────────────────────────────────────────────────────────────────────────────
-- Repository workspace picker
-- Scans a fixed list of directories for git repos (checking both the
-- directory itself and its immediate children), then shows a fuzzy picker.
-- Selecting an entry switches to (or creates) a workspace named after the
-- repo, with its cwd set to the repo path.
-- ─────────────────────────────────────────────────────────────────────────────
local repo_scan_dirs = settings.repoScanDirs or {}

local function find_repos()
  local repos = {}
  local seen = {}

  local function add(path)
    if not seen[path] then
      seen[path] = true
      table.insert(repos, path)
    end
  end

  for _, dir in ipairs(repo_scan_dirs) do
    -- Is the directory itself a repo?
    if #wezterm.glob('.git', dir) > 0 then
      add(dir)
    end
    -- Are any immediate children repos?
    -- wezterm.glob strips the relative_to prefix from results, so
    -- reconstruct the absolute path rather than using the match directly.
    for _, git_dir in ipairs(wezterm.glob('*/.git', dir)) do
      local child = git_dir:gsub('[/\\]%.git$', '')
      add(dir .. '\\' .. child)
    end
  end

  table.sort(repos)
  return repos
end

-- Returns the worktrees attached to the repo at `repo_path` (via `git
-- worktree list`), excluding the bare administrative entry if present.
-- A plain repo with no additional worktrees yields a single-element list.
local function git_worktrees(repo_path)
  local ok, stdout = wezterm.run_child_process {
    'git', '-C', repo_path, 'worktree', 'list', '--porcelain',
  }
  if not ok then return {} end

  local worktrees = {}
  local current
  for line in stdout:gmatch('[^\r\n]+') do
    local wt_path = line:match('^worktree (.+)$')
    if wt_path then
      current = { path = wt_path }
      table.insert(worktrees, current)
    elseif current then
      if line == 'bare' then
        current.bare = true
      elseif line == 'detached' then
        current.branch = '(detached)'
      elseif line:match('^prunable') then
        current.prunable = true
      else
        local branch = line:match('^branch (.+)$')
        if branch then
          current.branch = branch:gsub('^refs/heads/', '')
        end
      end
    end
  end

  local checkouts = {}
  for _, wt in ipairs(worktrees) do
    if not wt.bare and not wt.prunable then table.insert(checkouts, wt) end
  end
  return checkouts
end

-- `spawn_args`, if given, overrides the program run in the new workspace's
-- pane (default is the shell configured in config.default_prog).
local function switch_to_repo(window, pane, path, name, spawn_args)
  local spawn = { cwd = path }
  if spawn_args then spawn.args = spawn_args end
  window:perform_action(
    act.SwitchToWorkspace { name = name, spawn = spawn },
    pane
  )
end

local function pick_worktree(window, pane, repo_name, worktrees)
  local choices = {}
  for _, wt in ipairs(worktrees) do
    table.insert(choices, {
      id = wt.path,
      label = (wt.branch or wt.path) .. '  (' .. wt.path .. ')',
    })
  end

  window:perform_action(
    act.InputSelector {
      title = 'Worktrees: ' .. repo_name,
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, active_pane, id, label)
        if not id then return end
        local branch = label:match('^(.-)  %(')
        switch_to_repo(win, active_pane, id, repo_name .. ':' .. branch)
      end),
    },
    pane
  )
end

wezterm.on('pick-repo-workspace', function(window, pane)
  local choices = {}
  for _, repo in ipairs(find_repos()) do
    table.insert(choices, { id = repo, label = repo:match('([^/\\]+)$') })
  end

  window:perform_action(
    act.InputSelector {
      title = 'Repositories',
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, active_pane, id, label)
        if not id then return end
        local worktrees = git_worktrees(id)
        if #worktrees > 1 then
          pick_worktree(win, active_pane, label, worktrees)
        else
          switch_to_repo(win, active_pane, id, label)
        end
      end),
    },
    pane
  )
end)

-- Jumps straight into the Obsidian vault as its own workspace, opening
-- nvim (with obsidian.nvim configured against the same path) in it.
local notes_vault_path = 'C:\\projects\\notes'
local notes_spawn_args = {
  'C:/Program Files/PowerShell/7/pwsh.exe', '-NoLogo', '-NoExit', '-Command', 'nvim .',
}

wezterm.on('open-vault', function(window, pane)
  switch_to_repo(window, pane, notes_vault_path, 'notes', notes_spawn_args)
end)

-- True if `repo_path` is set up as a bare repo (the container/worktree-add
-- pattern), as opposed to a normal single-checkout clone.
local function is_bare_repo(repo_path)
  local ok, stdout = wezterm.run_child_process {
    'git', '-C', repo_path, 'rev-parse', '--is-bare-repository',
  }
  return ok and stdout:match('^%s*(%S+)') == 'true'
end

-- Creates a new worktree/branch under `repo_path`, mirroring the branch
-- name as the directory path (e.g. "feature/my_feature" ->
-- <repo_path>/feature/my_feature), then switches to a workspace for it.
-- `spawn_args`, if given, is forwarded to switch_to_repo. `pre_switch`, if
-- given, is called with the new worktree's path right before switching.
local function create_worktree(window, pane, repo_path, repo_name, branch, spawn_args, pre_switch)
  branch = branch:match('^%s*(.-)%s*$')
  if branch == '' then return end

  local existing = git_worktrees(repo_path)
  local base = existing[1] and existing[1].branch or nil

  local target_path = repo_path .. '/' .. branch
  local args = {
    'git', '-C', repo_path, 'worktree', 'add', '-b', branch, target_path,
  }
  if base then table.insert(args, base) end

  local ok, stdout, stderr = wezterm.run_child_process(args)
  if ok then
    if pre_switch then pre_switch(target_path) end
    switch_to_repo(window, pane, target_path, repo_name .. ':' .. branch, spawn_args)
  else
    window:toast_notification(
      'Worktree creation failed',
      (stderr ~= '' and stderr or stdout),
      nil,
      8000
    )
  end
end

-- Shared picker flow for both leader+n (plain) and leader+a (+ copilot):
-- pick a bare repo, prompt for a branch name, create the worktree.
-- `spawn_args`/`pre_switch`, if given, are forwarded to create_worktree.
local function prompt_new_worktree(window, pane, spawn_args, pre_switch)
  local choices = {}
  for _, repo in ipairs(find_repos()) do
    if is_bare_repo(repo) then
      table.insert(choices, { id = repo, label = repo:match('([^/\\]+)$') })
    end
  end

  window:perform_action(
    act.InputSelector {
      title = 'New worktree in...',
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, active_pane, id, label)
        if not id then return end
        win:perform_action(
          act.PromptInputLine {
            description = 'Branch name (e.g. feature/my_feature):',
            action = wezterm.action_callback(function(win2, pane2, branch)
              if branch and branch ~= '' then
                create_worktree(win2, pane2, id, label, branch, spawn_args, pre_switch)
              end
            end),
          },
          active_pane
        )
      end),
    },
    pane
  )
end

wezterm.on('new-worktree', function(window, pane)
  prompt_new_worktree(window, pane, nil)
end)

-- Same as new-worktree, but the pane runs copilot after opening (via
-- -NoExit so a normal shell is still there if copilot isn't installed
-- or exits).
local copilot_spawn_args = {
  'C:/Program Files/PowerShell/7/pwsh.exe', '-NoLogo', '-NoExit', '-Command', 'copilot',
}

-- Adds `path` to GitHub Copilot CLI's own trustedFolders list (in
-- %USERPROFILE%\.copilot\config.json) if not already present, so its
-- one-time "trust this folder?" prompt doesn't interrupt the first launch
-- in a freshly created worktree. The file has a leading `//` comment line
-- that isn't valid JSON, so that line is preserved separately around a
-- normal json_parse/json_encode round-trip of the rest. Best-effort: any
-- failure here just means the prompt shows once, same as before.
local function trust_folder_for_copilot(path)
  local home = os.getenv('USERPROFILE')
  if not home then return end
  local cfg_path = home .. '\\.copilot\\config.json'

  local f = io.open(cfg_path, 'r')
  if not f then return end
  local content = f:read('*a')
  f:close()

  local header_lines = {}
  local body = content
  while true do
    local first_line, rest = body:match('^(//[^\r\n]*)\r?\n(.*)$')
    if not first_line then break end
    table.insert(header_lines, first_line)
    body = rest
  end
  local header = #header_lines > 0 and (table.concat(header_lines, '\n') .. '\n') or ''

  local data = wezterm.json_parse(body)
  if not data then return end

  local normalized = path:gsub('/', '\\')
  data.trustedFolders = data.trustedFolders or {}
  for _, existing in ipairs(data.trustedFolders) do
    if existing:lower() == normalized:lower() then return end
  end
  table.insert(data.trustedFolders, normalized)

  local out = io.open(cfg_path, 'w')
  if not out then return end
  out:write(header .. wezterm.json_encode(data))
  out:close()
end

wezterm.on('new-worktree-copilot', function(window, pane)
  prompt_new_worktree(window, pane, copilot_spawn_args, trust_folder_for_copilot)
end)

-- Queries Azure DevOps (via `az boards query`) for Product Backlog Items,
-- Bugs, and Maintenance Backlog Items assigned to the current user,
-- excluding closed/removed items. Requires the
-- azure-devops CLI extension and `az login`, plus an "azureDevOps": {"org":
-- ..., "project": ...} entry in C:\projects\settings.json (see
-- load_settings above; org is the full URL, e.g. https://dev.azure.com/contoso).
-- Returns (pbis, nil) or (nil, error_message).
--
-- NOTE: az CLI isn't available on this machine to verify against, so the
-- JSON field parsing below (item.fields['System.Id'/'System.Title']) is
-- based on Azure DevOps's documented work-item JSON shape, not a live
-- test. If az boards query returns something shaped differently on your
-- end, this'll need adjusting.
local function query_my_pbis()
  local ado = settings.azureDevOps or {}
  local org = ado.org
  local project = ado.project
  if not org or org == '' or not project or project == '' then
    return nil, 'azureDevOps.org / azureDevOps.project not set in C:\\projects\\settings.json'
  end

  local wiql = "SELECT [System.Id], [System.Title] FROM WorkItems "
    .. "WHERE [System.WorkItemType] IN ('Product Backlog Item', 'Bug', 'Maintenance Backlog Item') "
    .. "AND [System.AssignedTo] = @Me "
    .. "AND [System.State] NOT IN ('Done', 'Removed', 'Closed') "
    .. "ORDER BY [System.ChangedDate] DESC"

  wezterm.log_warn 'wezterm: running az boards query...'

  -- run_child_process can throw (rather than return ok=false) if the
  -- program can't be spawned at all -- e.g. `az` resolving to `az.cmd` on
  -- Windows, which isn't a real PE executable. Uncaught, that error would
  -- propagate out of this action_callback and WezTerm just logs it, with
  -- no toast and no visible sign anything happened. pcall turns that into
  -- a normal error() -> toast the same as every other failure here.
  -- cmd /c ensures .cmd/.bat shims resolve correctly regardless of how
  -- run_child_process's underlying spawn behaves.
  local call_ok, ok, stdout, stderr = pcall(wezterm.run_child_process, {
    'cmd', '/c', 'az', 'boards', 'query', '--wiql', wiql, '--org', org, '--project', project, '-o', 'json',
  })
  if not call_ok then
    wezterm.log_warn('wezterm: az boards query threw: ' .. tostring(ok))
    return nil, 'failed to run az: ' .. tostring(ok)
  end
  if not ok then
    wezterm.log_warn('wezterm: az boards query failed: ' .. tostring(stderr))
    return nil, (stderr ~= '' and stderr or stdout)
  end
  wezterm.log_warn('wezterm: az boards query stdout: ' .. tostring(stdout))

  local items = wezterm.json_parse(stdout)
  if not items then return nil, 'failed to parse az boards query output' end

  local pbis = {}
  for _, item in ipairs(items) do
    local fields = item.fields or item
    local id = fields['System.Id'] or item.id
    local title = fields['System.Title']
    if id and title then
      table.insert(pbis, { id = tostring(id), title = title })
    end
  end
  return pbis, nil
end

wezterm.on('new-worktree-pbi', function(window, pane)
  local repo_choices = {}
  for _, repo in ipairs(find_repos()) do
    if is_bare_repo(repo) then
      table.insert(repo_choices, { id = repo, label = repo:match('([^/\\]+)$') })
    end
  end

  window:perform_action(
    act.InputSelector {
      title = 'New PBI worktree in...',
      choices = repo_choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, active_pane, repo_path, repo_label)
        if not repo_path then return end

        local pbis, err = query_my_pbis()
        if not pbis then
          win:toast_notification('Azure DevOps query failed', err or 'unknown error', nil, 8000)
          return
        end
        if #pbis == 0 then
          win:toast_notification('No PBIs found', 'No work items assigned to you matched the query', nil, 5000)
          return
        end

        local pbi_choices = {}
        for _, pbi in ipairs(pbis) do
          table.insert(pbi_choices, { id = pbi.id, label = '#' .. pbi.id .. '  ' .. pbi.title })
        end

        win:perform_action(
          act.InputSelector {
            title = 'PBIs assigned to you',
            choices = pbi_choices,
            fuzzy = true,
            action = wezterm.action_callback(function(win2, pane2, pbi_id, _)
              if not pbi_id then return end
              create_worktree(
                win2, pane2, repo_path, repo_label,
                'feature/' .. pbi_id, copilot_spawn_args, trust_folder_for_copilot
              )
            end),
          },
          active_pane
        )
      end),
    },
    pane
  )
end)

local function normalize_path(p)
  p = p:gsub('^file:///', '')
  p = p:gsub('\\', '/')
  p = p:gsub('/+$', '')
  return p:lower()
end

-- Kills any wezterm pane (anywhere in the mux, any window/workspace) whose
-- cwd is the given worktree path or a descendant of it, so Windows releases
-- its directory handle before we try to remove it. If the invoking pane
-- itself is one of them, the window is switched to the 'default' workspace
-- first so it isn't yanked out from under the user.
local function close_panes_under(window, active_pane, target_path)
  local target = normalize_path(target_path)
  local ok, stdout = wezterm.run_child_process { 'wezterm', 'cli', 'list', '--format', 'json' }
  if not ok then return end

  local panes = wezterm.json_parse(stdout)
  if not panes then return end

  local active_id = active_pane:pane_id()
  local kill_active = false

  for _, p in ipairs(panes) do
    local cwd = p.cwd and normalize_path(p.cwd) or ''
    if cwd == target or cwd:sub(1, #target + 1) == (target .. '/') then
      if p.pane_id == active_id then
        kill_active = true
      else
        wezterm.run_child_process { 'wezterm', 'cli', 'kill-pane', '--pane-id', tostring(p.pane_id) }
      end
    end
  end

  if kill_active then
    window:perform_action(act.SwitchToWorkspace { name = 'default' }, active_pane)
    wezterm.run_child_process { 'wezterm', 'cli', 'kill-pane', '--pane-id', tostring(active_id) }
  end
end

local function delete_worktree(window, pane, repo_path, worktree_path)
  close_panes_under(window, pane, worktree_path)

  local ok, stdout, stderr = wezterm.run_child_process {
    'git', '-C', repo_path, 'worktree', 'remove', worktree_path,
  }
  if ok then
    window:toast_notification('Worktree removed', worktree_path, nil, 5000)
  else
    window:toast_notification(
      'Worktree removal failed',
      (stderr ~= '' and stderr or stdout),
      nil,
      8000
    )
  end
end

local function pick_worktree_to_delete(window, pane, repo_path, repo_name, worktrees)
  local choices = {}
  for _, wt in ipairs(worktrees) do
    table.insert(choices, {
      id = wt.path,
      label = (wt.branch or wt.path) .. '  (' .. wt.path .. ')',
    })
  end

  window:perform_action(
    act.InputSelector {
      title = 'Delete worktree in: ' .. repo_name,
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, active_pane, id, label)
        if not id then return end
        win:perform_action(
          act.InputSelector {
            title = 'Delete ' .. label .. '?',
            choices = {
              { id = 'yes', label = 'Yes, delete it' },
              { id = 'no',  label = 'Cancel' },
            },
            action = wezterm.action_callback(function(win2, pane2, confirm_id)
              if confirm_id == 'yes' then
                delete_worktree(win2, pane2, repo_path, id)
              end
            end),
          },
          active_pane
        )
      end),
    },
    pane
  )
end

wezterm.on('delete-worktree', function(window, pane)
  local choices = {}
  for _, repo in ipairs(find_repos()) do
    if is_bare_repo(repo) then
      table.insert(choices, { id = repo, label = repo:match('([^/\\]+)$') })
    end
  end

  window:perform_action(
    act.InputSelector {
      title = 'Delete worktree from...',
      choices = choices,
      fuzzy = true,
      action = wezterm.action_callback(function(win, active_pane, id, label)
        if not id then return end
        local worktrees = git_worktrees(id)
        if #worktrees == 0 then
          win:toast_notification('No worktrees', label .. ' has no worktrees to delete', nil, 4000)
          return
        end
        pick_worktree_to_delete(win, active_pane, id, label, worktrees)
      end),
    },
    pane
  )
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
  -- Previous tab (next tab freed up leader+n for worktree creation below;
  -- Ctrl+Tab / Ctrl+Shift+Tab still cycle tabs via WezTerm's defaults)
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

  -- ── Scrollback ────────────────────────────────────────────────────────────
  { key = '[',    mods = 'LEADER', action = act.ActivateCopyMode },
  { key = ']',    mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

  -- ── Layout helpers ────────────────────────────────────────────────────────
  -- Toggle bottom pane to 30% / restore original height
  { key = 't', mods = 'LEADER', action = act.EmitEvent 'toggle-bottom-30' },

  -- ── Workspaces ────────────────────────────────────────────────────────────
  -- Fuzzy-pick a repository to switch/create a workspace for
  { key = 'w',   mods = 'LEADER', action = act.EmitEvent 'pick-repo-workspace' },
  -- Jump straight into the Obsidian vault workspace
  { key = 'o',   mods = 'LEADER', action = act.EmitEvent 'open-vault' },
  -- Create a new worktree (only offers repos set up as bare/worktree containers)
  { key = 'n',   mods = 'LEADER', action = act.EmitEvent 'new-worktree' },
  -- Create a new worktree, then launch copilot in it
  { key = 'a',   mods = 'LEADER', action = act.EmitEvent 'new-worktree-copilot' },
  -- Create a worktree from one of your assigned Azure DevOps PBIs, then launch copilot
  { key = 'A',   mods = 'LEADER', action = act.EmitEvent 'new-worktree-pbi' },
  -- Delete a worktree (closes any panes open in it first, then confirms)
  { key = 'd',   mods = 'LEADER', action = act.EmitEvent 'delete-worktree' },
  -- Fuzzy-pick an already-open workspace
  { key = 'Tab', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'WORKSPACES' } },
  -- Create or switch to a named workspace
  {
    key  = 'W',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Workspace name:',
      action = wezterm.action_callback(function(window, _, name)
        if name and #name > 0 then
          window:perform_action(act.SwitchToWorkspace { name = name }, window:active_pane())
        end
      end),
    },
  },
  -- Next / previous workspace
  { key = '.', mods = 'LEADER', action = act.SwitchWorkspaceRelative(1)  },
  { key = ',', mods = 'LEADER', action = act.SwitchWorkspaceRelative(-1) },

  -- ── Misc ──────────────────────────────────────────────────────────────────
  -- Reload config
  { key = 'R',    mods = 'LEADER', action = act.ReloadConfiguration },
  -- Show debug overlay
  { key = '`',    mods = 'LEADER', action = act.ShowDebugOverlay },
}

return config
