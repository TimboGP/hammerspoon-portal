local M = {}

local function shellQuote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end
M.shellQuote = shellQuote

-- Percent-encodes everything but URL-safe characters, for building a
-- file:// URL out of an arbitrary filesystem path.
local function urlEncodePath(path)
  return (path:gsub("([^%w%-%_%.%~/])", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

function M.open(portal)
  if portal.kind == "app" then
    hs.application.launchOrFocus(portal.name)
  else
    hs.execute("open " .. shellQuote(portal.path))
  end
end

-- Hands the portal's path to Dropover via its documented `open -a Dropover
-- -- <path>` terminal-import hook, creating a shelf (or adding to the
-- frontmost one) with it. Works for any kind - Dropover treats a folder or
-- .app bundle as just another path.
function M.sendToShelf(portal)
  hs.execute("open -a Dropover -- " .. shellQuote(portal.path))
end

-- Opens a plain new Finder window (not tied to any portal), same as
-- Finder's own Cmd+N. `open -na Finder` alone doesn't always spawn a window
-- when Finder is already running, so this drives Finder directly.
function M.openNewFinderWindow()
  hs.osascript.applescript([[
    tell application "Finder"
      make new Finder window
      activate
    end tell
  ]])
end

-- kind: "file" writes an NSURL file object (Finder-pasteable); "path" writes
-- a plain path string. Defaults to config.defaultCopyKind.
function M.copy(portal, kind)
  if kind == "path" then
    hs.pasteboard.setContents(portal.path)
  else
    hs.pasteboard.writeObjects({ url = "file://" .. urlEncodePath(portal.path) })
  end
end

return M
