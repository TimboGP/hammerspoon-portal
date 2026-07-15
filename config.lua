local home = os.getenv("HOME")

return {
  leader = { { "cmd", "ctrl", "alt" }, "p" },
  modalIdleTimeout = 3.5,

  storagePath = home .. "/.hammerspoon/portal.json",

  chooserWidth = 35,

  -- Default copy shape when hitting `c`. "file" writes an NSURL file object
  -- (Finder-pasteable); "path" writes a plain path string. Hold shift while
  -- selecting a chooser row to get the other shape for that one copy.
  defaultCopyKind = "file",
}
