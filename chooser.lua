local M = {}

local function rowFor(portal)
  return {
    text = portal.name,
    subText = portal.path,
    image = hs.image.iconForFile(portal.path),
    portal = portal,
  }
end

--- Fuzzy chooser over `portals`. Calls `callback(portal, event)` on
--- selection, or `callback(nil)` if the user cancels. `event` is the table
--- from hs.chooser's completion callback (`{mods = {...}}` etc.) so callers
--- can branch on a held modifier (e.g. shift-copy for the alternate kind).
function M.pick(portals, placeholderText, callback)
  if #portals == 0 then
    hs.alert.show("Portal: no portals saved yet (add one with `a`)", 2)
    return
  end

  local rows = {}
  for _, p in ipairs(portals) do table.insert(rows, rowFor(p)) end

  local ch = hs.chooser.new(function(choice)
    if not choice then
      callback(nil)
    else
      callback(choice.portal)
    end
  end)
  ch:placeholderText(placeholderText)
  ch:choices(rows)
  ch:show()
end

--- Single-field free text entry, built on hs.chooser (a lone static row so
--- Enter always fires with whatever the user typed/left in the query
--- field). Used for manual paths and naming portals during add/rename.
function M.textPrompt(placeholderText, defaultQuery, callback)
  local ch
  ch = hs.chooser.new(function(choice)
    if not choice then
      callback(nil)
    else
      callback(ch:query())
    end
  end)
  ch:placeholderText(placeholderText)
  ch:choices({ { text = placeholderText } })
  ch:query(defaultQuery or "")
  ch:show()
end

return M
