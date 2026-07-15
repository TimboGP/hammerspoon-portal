local M = {}

local function shellQuote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

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
