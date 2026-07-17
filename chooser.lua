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

--- Single-field free text entry via a native OS dialog (hs.dialog.textPrompt),
--- not hs.chooser — a chooser fuzzy-filters its choice list against the typed
--- query, so free text that doesn't match a placeholder row leaves nothing to
--- select and Enter never fires. Used for manual paths and naming portals
--- during add/rename.
function M.textPrompt(title, defaultQuery, callback)
  local button, text = hs.dialog.textPrompt(title, "", defaultQuery or "", "OK", "Cancel")
  if button ~= "OK" or not text or text == "" then
    callback(nil)
    return
  end
  callback(text)
end

return M
