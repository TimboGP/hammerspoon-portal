local M = {}

local function timestamp()
  return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

--- Prompts for a name for `candidate` ({name, path, kind}) and saves it,
--- pre-filling the name field with the capture source's own guess.
local function addCandidate(store, chooser, candidate)
  chooser.textPrompt("Portal: save as", candidate.name, function(name)
    if not name or name == "" then return end
    store.add({ name = name, path = candidate.path, kind = candidate.kind, createdAt = timestamp() })
    hs.alert.show("Portal: added \"" .. name .. "\"", 1.5)
  end)
end

-- Capture priority: Finder selection, then the frontmost (non-Finder) app,
-- then a manual path prompt if neither yields anything.
local function addPortal(store, capture, chooser)
  local selection = capture.finderSelection()
  if #selection > 0 then
    for _, path in ipairs(selection) do
      local candidate, err = capture.fromManualPath(path)
      if candidate then
        addCandidate(store, chooser, candidate)
      else
        hs.alert.show("Portal: " .. err, 2)
      end
    end
    return
  end

  local appCandidate = capture.frontmostApp()
  if appCandidate then
    addCandidate(store, chooser, appCandidate)
    return
  end

  chooser.textPrompt("Portal: path to add", "~/", function(path)
    if not path or path == "" then return end
    local candidate, err = capture.fromManualPath(path)
    if not candidate then
      hs.alert.show("Portal: " .. err, 2)
      return
    end
    addCandidate(store, chooser, candidate)
  end)
end

local function openPortal(store, chooser, actions)
  chooser.pick(store.list(), "Portal: open", function(portal)
    if portal then actions.open(portal) end
  end)
end

local function copyPortal(store, chooser, actions, config)
  chooser.pick(store.list(), "Portal: copy (shift for the other kind)", function(portal)
    if not portal then return end
    local kind = config.defaultCopyKind
    if hs.eventtap.checkKeyboardModifiers().shift then
      kind = (kind == "file") and "path" or "file"
    end
    actions.copy(portal, kind)
    hs.alert.show("Portal: copied " .. kind .. " (\"" .. portal.name .. "\")", 1.5)
  end)
end

local function sendToShelf(store, chooser, actions)
  chooser.pick(store.list(), "Portal: send to Dropover shelf", function(portal)
    if portal then actions.sendToShelf(portal) end
  end)
end

local function managePortal(store, chooser)
  chooser.pick(store.list(), "Portal: delete", function(portal)
    if not portal then return end
    local button = hs.dialog.blockAlert(
      "Delete portal \"" .. portal.name .. "\"?",
      portal.path,
      "Delete", "Cancel"
    )
    if button == "Delete" then
      store.remove(portal.name)
      hs.alert.show("Portal: deleted \"" .. portal.name .. "\"", 1.5)
    end
  end)
end

-- `deps` = { store, capture, chooser, actions } - the sibling Spoon modules
-- this one wires together; passed in rather than required so every module
-- stays a plain dofile()'d table (matches this repo's other Spoons).
function M.start(config, deps)
  local store, capture, chooser, actions, flatten = deps.store, deps.capture, deps.chooser, deps.actions, deps.flatten

  -- Unbound: entry is now driven by the shared keybind_registry (see
  -- init.lua's registration under path {"o"}), not a direct hs.hotkey bind
  -- on config.leader here.
  local modal = hs.hotkey.modal.new()
  local idleTimer = nil

  -- `fn` is included so callers other than the modal itself (the menu bar's
  -- shortcut list) can trigger the exact same action by click, not just by
  -- key - a single source of truth for what each shortcut does.
  local bindings = {
    { key = "a", short = "add", description = "add (Finder selection / frontmost app / manual path)",
      fn = function() addPortal(store, capture, chooser) end },
    { key = "o", short = "open", description = "open picked portal",
      fn = function() openPortal(store, chooser, actions) end },
    { key = "c", short = "copy", description = "copy picked portal (shift = alternate kind)",
      fn = function() copyPortal(store, chooser, actions, config) end },
    { key = "d", short = "delete", description = "delete picked portal",
      fn = function() managePortal(store, chooser) end },
    { key = "s", short = "shelf", description = "send picked portal to Dropover shelf",
      fn = function() sendToShelf(store, chooser, actions) end },
    { key = "f", short = "flatten", description = "flatten Finder-selected/picked directory's subfolder up (shift = copy instead of move)",
      fn = function() flatten.pick(store, chooser, actions, capture) end },
    { key = "n", short = "new window", description = "open a new Finder window",
      fn = function() actions.openNewFinderWindow() end },
  }
  M._bindings = bindings

  local row = {}
  for _, b in ipairs(bindings) do
    table.insert(row, b.key .. " " .. b.short)
  end
  local cheatSheet = "Portal leader engaged\n" .. table.concat(row, " | ") .. " | esc cancel"

  local function resetIdleTimer()
    if idleTimer then idleTimer:stop() end
    idleTimer = hs.timer.doAfter(config.modalIdleTimeout, function()
      modal:exit()
    end)
  end

  function modal:entered()
    hs.alert.show(cheatSheet, 3)
    resetIdleTimer()
  end

  function modal:exited()
    if idleTimer then
      idleTimer:stop()
      idleTimer = nil
    end
  end

  for _, b in ipairs(bindings) do
    modal:bind({}, b.key, nil, function()
      modal:exit()
      b.fn()
    end)
  end
  modal:bind({}, "escape", nil, function() modal:exit() end)

  M.instance = modal
  return modal
end

-- Structured {key, short, description} rows for the leader modal's binds,
-- built once in M.start(); consumed by CheatSheet.spoon.
function M.bindings()
  return M._bindings or {}
end

return M
