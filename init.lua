--- === Portal ===
---
--- Save named portals to files, directories, and apps, then jump to (open) or
--- copy them instantly via a fuzzy chooser. See the repo README for setup.

local obj = {}
obj.__index = obj

obj.name = "Portal"
obj.version = "0.1.0"
obj.author = "tboehm"
obj.license = "MIT"
obj.homepage = "https://github.com/TimboGP/hammerspoon-portal"

obj.spoonPath = hs.spoons.scriptPath()

local config = dofile(obj.spoonPath .. "config.lua")
local store = dofile(obj.spoonPath .. "store.lua")
local capture = dofile(obj.spoonPath .. "capture.lua")
local chooser = dofile(obj.spoonPath .. "chooser.lua")
local actions = dofile(obj.spoonPath .. "actions.lua")
local menubar = dofile(obj.spoonPath .. "menubar.lua")
local modal = dofile(obj.spoonPath .. "modal.lua")

function obj:init()
  self.config = config
end

function obj:start()
  store.start(self.config)
  menubar.start(store, actions)
  modal.start(self.config, {
    store = store,
    capture = capture,
    chooser = chooser,
    actions = actions,
  })
  return self
end

function obj:stop()
  menubar.stop()
  return self
end

return obj
