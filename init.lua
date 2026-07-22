--- === Portal ===
---
--- Save named portals to files, directories, and apps, then jump to (open) or
--- copy them instantly via a fuzzy chooser. See the repo README for setup.

local obj = {}
obj.__index = obj

obj.name = "Portal"
obj.version = "0.2.0"
obj.author = "tboehm"
obj.license = "MIT"
obj.homepage = "https://github.com/TimboGP/hammerspoon-portal"

obj.spoonPath = hs.spoons.scriptPath()

local config = dofile(obj.spoonPath .. "config.lua")
local store = dofile(obj.spoonPath .. "store.lua")
local capture = dofile(obj.spoonPath .. "capture.lua")
local chooser = dofile(obj.spoonPath .. "chooser.lua")
local actions = dofile(obj.spoonPath .. "actions.lua")
local flatten = dofile(obj.spoonPath .. "flatten.lua")
local menubar = dofile(obj.spoonPath .. "menubar.lua")
local modal = dofile(obj.spoonPath .. "modal.lua")
local dropover = dofile(obj.spoonPath .. "dropover.lua")
local KeybindRegistry = require("keybind_registry")

function obj:init()
  self.config = config
end

function obj:start()
  store.start(self.config)
  modal.start(self.config, {
    store = store,
    capture = capture,
    chooser = chooser,
    actions = actions,
    flatten = flatten,
  })
  menubar.start(store, actions, {
    bindings = modal.bindings(),
    iconSize = self.config.menubarIconSize,
    spoonPath = obj.spoonPath,
    chooser = chooser,
    flatten = flatten,
  })

  -- The leader combo itself is owned by Leader.spoon; this just registers
  -- the "o" (Open) domain's single entry point, which still opens this
  -- Spoon's own pre-existing flat verb menu one level in (see
  -- shortcut-system.md's "o domain detail (macOS)").
  KeybindRegistry.bind({
    scope = "leader",
    path = { "o" },
    desc = "open (portals)",
    fn = function() modal.instance:enter() end,
    spoonName = self.name,
  })

  return self
end

-- Entry point for Dropover's "Custom Scripts" shelf action, invoked via
-- `hs -c` (see dropover-send-to-portal.sh) with the shelf's file paths
-- newline-joined into `pathsText`.
function obj:receiveFromShelf(pathsText)
  dropover.receiveFiles(store, chooser, actions, pathsText)
  return self
end

function obj:stop()
  KeybindRegistry.unbindBySpoon(self.name)
  menubar.stop()
  return self
end

--- Structured {key, short, description} rows for the leader modal's
--- bindings, for external cheat-sheet tools (e.g. CheatSheet.spoon) to query.
function obj:bindings()
  return modal.bindings()
end

return obj
