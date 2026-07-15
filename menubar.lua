local M = {}

local item = nil

function M.start(store, actions)
  item = hs.menubar.new()
  item:setTitle("⛩")

  local function rebuildMenu()
    local menu = {}
    for _, portal in ipairs(store.list()) do
      table.insert(menu, {
        title = portal.name,
        menu = {
          { title = "Open", fn = function() actions.open(portal) end },
          { title = "Copy", fn = function() actions.copy(portal) end },
        },
      })
    end
    if #menu == 0 then
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
