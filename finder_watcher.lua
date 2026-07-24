local M = {}

local wf = nil
local lastPath = nil
local zoxide = nil

-- Resolves the frontmost Finder window's current folder, the same way
-- capture.finderSelection() resolves the current selection: no native
-- Hammerspoon API for this, so shell out via AppleScript. Non-filesystem
-- views (search results, tags, Recents, AirDrop, Network, Computer) throw on
-- `target of front window as alias`, so the try/on error mirrors
-- capture.lua's existing convention of returning "" rather than erroring.
local TARGET_SCRIPT = [[
  tell application "Finder"
    try
      if (count of windows) = 0 then return ""
      return POSIX path of (target of front window as alias)
    on error
      return ""
    end try
  end tell
]]

local function onFinderEvent()
  -- Only the frontmost Finder window counts as "visited" - a background
  -- window sitting on a stale folder shouldn't get credit just because some
  -- unrelated window-filter event fires.
  local frontApp = hs.application.frontmostApplication()
  if not frontApp or frontApp:name() ~= "Finder" then return end

  local ok, path = hs.osascript.applescript(TARGET_SCRIPT)
  if not ok or not path or path == "" then return end

  path = path:gsub("/$", "")
  if path == lastPath then return end
  lastPath = path

  zoxide.add(path)
end

function M.start(config, deps)
  zoxide = deps.zoxide
  if not zoxide.available() then return end

  wf = hs.window.filter.new(false):setAppFilter("Finder", {})
  wf:subscribe(
    { hs.window.filter.windowFocused, hs.window.filter.windowTitleChanged },
    onFinderEvent
  )
end

function M.stop()
  if wf then
    wf:unsubscribeAll()
    wf = nil
  end
  lastPath = nil
end

return M
