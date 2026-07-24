local M = {}

local binPath = nil

local function shellQuote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function existingFile(path)
  if not path or path == "" then return nil end
  local attrs = hs.fs.attributes(path)
  if attrs and attrs.mode ~= "directory" then return path end
  return nil
end

-- Resolves an absolute path to the `zoxide` binary once, since hs.execute's
-- default /bin/sh doesn't inherit the login shell's Homebrew PATH. Tries, in
-- order: config.zoxideBin, `command -v` under the user's actual login shell,
-- then the common Homebrew install locations.
function M.start(config)
  binPath = existingFile(config.zoxideBin)

  if not binPath then
    local output, ok = hs.execute("command -v zoxide", true)
    if ok and output then
      binPath = existingFile(output:gsub("%s+$", ""))
    end
  end

  if not binPath then
    binPath = existingFile("/opt/homebrew/bin/zoxide") or existingFile("/usr/local/bin/zoxide")
  end
end

function M.available()
  return binPath ~= nil
end

-- Records a visit (increments rank, or inserts a new entry). Fire-and-forget
-- - failures (e.g. the path matches the user's own _ZO_EXCLUDE_DIRS) are
-- ignored silently, since this is best-effort tracking, not a critical write.
function M.add(path)
  if not binPath then return end
  hs.execute(shellQuote(binPath) .. " add " .. shellQuote(path))
end

-- Returns every directory zoxide knows about as { {path=, score=}, ... },
-- already sorted best-first by frecency (zoxide's own `-l -s` output order)
-- - no scoring or sorting needed on Portal's side.
function M.list()
  if not binPath then return {} end
  local output, ok = hs.execute(shellQuote(binPath) .. " query -l -s")
  if not ok or not output then return {} end

  local entries = {}
  for line in output:gmatch("[^\n]+") do
    local score, path = line:match("^%s*(%S+)%s+(.+)$")
    if score and path then
      table.insert(entries, { path = path, score = tonumber(score) })
    end
  end
  return entries
end

return M
