local M = {}

local function splitLines(text)
  local lines = {}
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if line ~= "" then table.insert(lines, line) end
  end
  return lines
end

-- Called from Dropover's "Custom Scripts" hook (see dropover-send-to-
-- portal.sh) via `hs -c`, with the shelf's file paths newline-joined into
-- `pathsText`. Prompts for which saved *directory* portal to file them
-- into, then moves (or, holding shift, copies) each one there.
function M.receiveFiles(store, chooser, actions, pathsText)
  local paths = splitLines(pathsText)
  if #paths == 0 then return end

  local directories = {}
  for _, p in ipairs(store.list()) do
    if p.kind == "directory" then table.insert(directories, p) end
  end

  chooser.pick(directories, "Portal: send " .. #paths .. " shelf item(s) to", function(portal)
    if not portal then return end
    local copy = hs.eventtap.checkKeyboardModifiers().shift
    local cmd = copy and "cp -R" or "mv"
    for _, path in ipairs(paths) do
      hs.execute(cmd .. " " .. actions.shellQuote(path) .. " " .. actions.shellQuote(portal.path))
    end
    hs.alert.show(
      "Portal: " .. (copy and "copied " or "moved ") .. #paths .. " item(s) to \"" .. portal.name .. "\"",
      1.5
    )
  end)
end

return M
