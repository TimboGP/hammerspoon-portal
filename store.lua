local M = {}

local storagePath = nil
local portals = {}

local function load()
  local f = io.open(storagePath, "r")
  if not f then
    portals = {}
    return
  end
  local contents = f:read("*a")
  f:close()

  local ok, decoded = pcall(hs.json.decode, contents)
  portals = (ok and decoded and decoded.portals) or {}
end

local function persist()
  local f = io.open(storagePath, "w")
  if not f then
    hs.alert.show("Portal: failed to write " .. storagePath, 2)
    return
  end
  f:write(hs.json.encode({ portals = portals }))
  f:close()
end

function M.start(config)
  storagePath = config.storagePath
  load()
end

function M.list()
  return portals
end

function M.find(name)
  for _, p in ipairs(portals) do
    if p.name == name then return p end
  end
  return nil
end

-- Adds `portal`, replacing any existing entry with the same name.
function M.add(portal)
  for i, p in ipairs(portals) do
    if p.name == portal.name then
      portals[i] = portal
      persist()
      return
    end
  end
  table.insert(portals, portal)
  persist()
end

function M.remove(name)
  for i, p in ipairs(portals) do
    if p.name == name then
      table.remove(portals, i)
      persist()
      return true
    end
  end
  return false
end

return M
