local M = {}

--- Fuzzy chooser over every directory zoxide knows about (Finder visits
--- tracked by finder_watcher.lua, plus whatever the user's already `cd`'d to
--- in a terminal - one shared frecency database), pre-sorted best-first.
--- Enter reveals the picked directory in Finder via the same `actions.open`
--- every other Portal action already uses.
function M.pick(zoxide, chooser, actions)
  if not zoxide.available() then
    hs.alert.show("Portal: zoxide not found (brew install zoxide)", 2)
    return
  end

  local entries = zoxide.list()
  if #entries == 0 then
    hs.alert.show("Portal: no visited directories yet", 2)
    return
  end

  local rows = {}
  for _, e in ipairs(entries) do
    local name = e.path:match("([^/]+)/?$") or e.path
    table.insert(rows, { name = name, path = e.path, kind = "directory" })
  end

  chooser.pick(rows, "Portal: jump", function(picked)
    if picked then actions.open(picked) end
  end)
end

return M
