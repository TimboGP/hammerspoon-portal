local M = {}

--- Classifies a filesystem path into a portal `kind`. A `.app` bundle is
--- technically a directory on disk but should read as "app" to the user, so
--- the extension check runs before the directory check.
local function classify(path)
  if path:match("%.app/?$") then return "app" end
  local attrs = hs.fs.attributes(path)
  if not attrs then return nil end
  if attrs.mode == "directory" then return "directory" end
  return "file"
end
M.classify = classify

--- Returns the POSIX paths of every item selected in the frontmost Finder
--- window, or {} if Finder isn't frontmost or has no selection. Hammerspoon
--- has no native Finder selection API, so this shells out via AppleScript.
function M.finderSelection()
  local frontApp = hs.application.frontmostApplication()
  if not frontApp or frontApp:name() ~= "Finder" then return {} end

  local script = [[
    tell application "Finder"
      set theSelection to selection
      set thePaths to {}
      repeat with anItem in theSelection
        set end of thePaths to POSIX path of (anItem as alias)
      end repeat
      set AppleScript's text item delimiters to linefeed
      return thePaths as text
    end tell
  ]]
  local ok, result = hs.osascript.applescript(script)
  if not ok or not result or result == "" then return {} end

  local paths = {}
  for line in (result .. "\n"):gmatch("(.-)\n") do
    if line ~= "" then table.insert(paths, line) end
  end
  return paths
end

--- Returns {name, path, kind} for the frontmost app, or nil if there isn't
--- one (or it's Finder, which is handled via finderSelection instead).
function M.frontmostApp()
  local app = hs.application.frontmostApplication()
  if not app or app:name() == "Finder" then return nil end
  local path = app:path()
  if not path then return nil end
  return { name = app:name(), path = path, kind = "app" }
end

--- Builds a {name, path, kind} candidate from a manual (tilde-expandable)
--- path, or nil + an error message if it doesn't resolve to anything.
function M.fromManualPath(path)
  path = path:gsub("^~", os.getenv("HOME"))
  local kind = classify(path)
  if not kind then return nil, "no such file or directory: " .. path end
  local name = path:match("([^/]+)/?$") or path
  name = name:gsub("%.app$", "")
  return { name = name, path = path, kind = kind }
end

return M
