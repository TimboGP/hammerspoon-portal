local home = os.getenv("HOME")

return {
  leader = { { "cmd", "ctrl", "alt" }, "p" },
  modalIdleTimeout = 3.5,

  storagePath = home .. "/.hammerspoon/portal.json",

  chooserWidth = 35,

  -- Point size for the menu bar glyph (⛩). The default system menu bar font
  -- size renders the torii emoji noticeably smaller than the icon-based menu
  -- bar items other apps install; bump this if it still looks small/large
  -- next to your other menu bar icons.
  menubarIconSize = 18,

  -- Default copy shape when hitting `c`. "file" writes an NSURL file object
  -- (Finder-pasteable); "path" writes a plain path string. Hold shift while
  -- selecting a chooser row to get the other shape for that one copy.
  defaultCopyKind = "file",
}
