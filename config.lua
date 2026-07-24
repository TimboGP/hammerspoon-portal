local home = os.getenv("HOME")

return {
  -- No longer binds its own physical leader combo - reached via the shared
  -- Leader.spoon tree at path {"o"} (default ⌘⌃⌥Space → o). See
  -- dotfiles' shortcut-system.md and modal.lua / init.lua's obj:start().
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

  -- Absolute path to the `zoxide` binary, for the `j` (jump) action. nil
  -- auto-detects it (via `command -v` under the user's login shell, then the
  -- common Homebrew install locations) - only set this if zoxide lives
  -- somewhere non-standard.
  zoxideBin = nil,
}
