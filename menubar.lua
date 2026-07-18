local M = {}

local item = nil

--- Structured shortcut list: a disabled note on how to reach this modal
--- (it's reached through the shared Leader.spoon tree now, not its own
--- physical combo - see shortcut-system.md's "o domain detail") plus one
--- clickable row per leader-modal binding, e.g. "  a  add", that runs the
--- exact same function as pressing that key in the modal.
local function shortcutMenuItems(bindings)
  local items = {}
  table.insert(items, { title = "Leader: ⌘⌃⌥Space → o", disabled = true })
  for _, b in ipairs(bindings or {}) do
    table.insert(items, { title = "  " .. b.key .. "  " .. b.short, fn = b.fn })
  end
  return items
end

function M.start(store, actions, options)
  options = options or {}
  item = hs.menubar.new()
  if options.iconSize then
    item:setTitle(hs.styledtext.new("⛩", { font = { size = options.iconSize } }))
  else
    item:setTitle("⛩")
  end

  local function rebuildMenu()
    local menu = {}

    if options.bindings then
      for _, entry in ipairs(shortcutMenuItems(options.bindings)) do
        table.insert(menu, entry)
      end
      table.insert(menu, { title = "-" })
    end

    for _, portal in ipairs(store.list()) do
      table.insert(menu, {
        title = portal.name,
        menu = {
          { title = "Open", fn = function() actions.open(portal) end },
          { title = "Copy", fn = function() actions.copy(portal) end },
        },
      })
    end
    if #store.list() == 0 then
      table.insert(menu, { title = "No portals yet", disabled = true })
    end
    item:setMenu(menu)
  end

  item:setMenu(rebuildMenu)
  return item
end

function M.stop()
  if item then
    item:delete()
    item = nil
  end
end

return M
