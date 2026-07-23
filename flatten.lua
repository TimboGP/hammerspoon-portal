local M = {}

--- Sorted names of `path`'s immediate subdirectories.
local function subdirectories(path)
  local names = {}
  local iter = hs.fs.dir(path)
  if not iter then return names end
  for entry in iter do
    if entry ~= "." and entry ~= ".." then
      local attrs = hs.fs.attributes(path .. "/" .. entry)
      if attrs and attrs.mode == "directory" then table.insert(names, entry) end
    end
  end
  table.sort(names)
  return names
end

--- Moves (or, with `copy`, copies) every item directly inside
--- `dirPath/subdirName` up into `dirPath` itself, leaving the now-emptied
--- subdirectory in place rather than removing it. Skips any item whose name
--- already exists in `dirPath` instead of overwriting it. Returns
--- (movedCount, skippedNames).
local function flattenSubdirectory(actions, dirPath, subdirName, copy)
  local subdirPath = dirPath .. "/" .. subdirName
  local moved, skipped = 0, {}
  local iter = hs.fs.dir(subdirPath)
  if not iter then return 0, skipped end
  for entry in iter do
    if entry ~= "." and entry ~= ".." then
      local dest = dirPath .. "/" .. entry
      if hs.fs.attributes(dest) then
        table.insert(skipped, entry)
      else
        local cmd = (copy and "cp -R " or "mv ")
          .. actions.shellQuote(subdirPath .. "/" .. entry) .. " " .. actions.shellQuote(dirPath) .. "/"
        hs.execute(cmd)
        moved = moved + 1
      end
    end
  end
  return moved, skipped
end

local function report(copy, subdirName, moved, skipped)
  local verb = copy and "Copied" or "Moved"
  local msg = "Portal: " .. verb .. " " .. moved .. " item(s) out of \"" .. subdirName .. "\""
  if #skipped > 0 then
    msg = msg .. " (skipped " .. #skipped .. " existing: " .. table.concat(skipped, ", ") .. ")"
  end
  hs.alert.show(msg, 2.5)
end

--- Flattens one of `portal`'s immediate subdirectories up into `portal`
--- itself. With exactly one subdirectory, acts on it directly; with more
--- than one, prompts via `chooser` for which; with none, alerts and does
--- nothing. Holding shift copies instead of the default move.
function M.run(chooser, actions, portal)
  if portal.kind ~= "directory" then
    hs.alert.show("Portal: \"" .. portal.name .. "\" isn't a directory", 2)
    return
  end

  local copy = hs.eventtap.checkKeyboardModifiers().shift
  local subdirs = subdirectories(portal.path)
  if #subdirs == 0 then
    hs.alert.show("Portal: no subfolder found in \"" .. portal.name .. "\"", 2)
    return
  end

  local function flatten(subdirName)
    local moved, skipped = flattenSubdirectory(actions, portal.path, subdirName, copy)
    report(copy, subdirName, moved, skipped)
  end

  if #subdirs == 1 then
    flatten(subdirs[1])
    return
  end

  local rows = {}
  for _, name in ipairs(subdirs) do
    table.insert(rows, { name = name, path = portal.path .. "/" .. name, kind = "directory" })
  end
  chooser.pick(rows, "Portal: which subfolder to flatten", function(sub)
    if sub then flatten(sub.name) end
  end)
end

--- Modal entry point: prefers the current Finder selection (mirrors
--- addPortal's capture-first behavior in modal.lua) so a directory can be
--- flattened without saving it as a portal first. With no directory in the
--- Finder selection, falls back to picking a saved portal.
function M.pick(store, chooser, actions, capture)
  local selected = {}
  if capture then
    for _, path in ipairs(capture.finderSelection()) do
      local candidate = capture.fromManualPath(path)
      if candidate and candidate.kind == "directory" then table.insert(selected, candidate) end
    end
  end

  if #selected == 1 then
    M.run(chooser, actions, selected[1])
    return
  end

  if #selected > 1 then
    chooser.pick(selected, "Portal: which selected folder to flatten", function(dir)
      if dir then M.run(chooser, actions, dir) end
    end)
    return
  end

  chooser.pick(store.list(), "Portal: flatten subfolder (shift = copy)", function(portal)
    if portal then M.run(chooser, actions, portal) end
  end)
end

return M
