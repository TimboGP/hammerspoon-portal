# hammerspoon-portal

A [Hammerspoon](https://www.hammerspoon.org/) Spoon for saving named
**portals** to files, directories, and apps, then jumping to (open) or
copying them instantly via a fuzzy chooser.

A portal is `{ name, path, kind, createdAt }`, where `kind` is `file`,
`directory`, or `app`. Portals persist across Hammerspoon reloads in
`~/.hammerspoon/portal.json`.

## Status

- [x] **M0** — Spoon scaffold, config, leader-key modal with idle-timeout
- [x] **M1** — JSON persistence (`store.lua`), loaded on start, written on
      every mutation
- [x] **M2** — Capture: Finder selection (via AppleScript, no native API
      exists), frontmost app, and manual path entry — auto-detects `kind`
      from the path itself (`.app` bundle vs. directory vs. file), no
      prompt needed
- [x] **M3** — Open (`o`): reveals files/directories via `open`, launches or
      focuses apps by name
- [x] **M4** — Copy (`c`): writes an NSURL file object by default
      (Finder-pasteable, not just a path string), with a shift-modifier
      toggle for the other shape
- [x] **M5** — Manage (`d`): fuzzy delete with a confirmation dialog
- [x] **M6** — Menu bar mirror of every portal's open/copy actions
- [x] **M7** — [Dropover](https://dropoverapp.com/) integration (`s`):
      push a portal onto a Dropover shelf, and pull shelf items into a
      saved directory portal from Dropover's own Actions menu

## Install

This repo's root *is* the Spoon (no `Portal.spoon/` subfolder) — clone it
directly into your Spoons directory, naming the local checkout
`Portal.spoon` (Hammerspoon matches on the local folder name, not the git
remote's name):

```sh
git clone https://github.com/TimboGP/hammerspoon-portal.git ~/.hammerspoon/Spoons/Portal.spoon
```

Or, if you keep a separate working copy elsewhere, symlink it in instead:

```sh
ln -s /path/to/your/clone ~/.hammerspoon/Spoons/Portal.spoon
```

In `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("Portal")
spoon.Portal:start()
```

Reload Hammerspoon's config after editing (menu bar icon → Reload Config).

## Usage

- Leader: `⌘⌃⌥Space → o` (via the shared `Leader.spoon` + `keybind_registry`
  — see `dotfiles/shortcut-system.md`; this Spoon no longer binds its own
  physical combo). Press it to enter the modal; an alert confirms entry and
  lists the keys below. Press `esc`, or wait ~3.5s idle, to exit.
- **Add** (`a`): captures a candidate in this priority order — every item
  currently selected in the frontmost Finder window, otherwise the
  frontmost (non-Finder) app's bundle, otherwise a manual-path prompt
  (`~`-expanded). Then prompts for a name, pre-filled with the capture's own
  guess (filename, or app name), and saves it.
- **Open** (`o`): fuzzy chooser (name + path subtext + Finder icon) over
  every saved portal; Enter opens it — `open` for files/directories, launch-
  or-focus for apps.
- **Copy** (`c`): same chooser; Enter copies the portal per
  `config.defaultCopyKind` (`"file"` by default — an NSURL file object, so
  it pastes as an actual file in Finder, not a text path). Hold shift while
  selecting to copy the other shape (plain path string) instead for that
  one copy.
- **Delete** (`d`): same chooser; Enter prompts to confirm, then removes the
  picked portal.
- **Send to shelf** (`s`): same chooser; Enter hands the portal's path to
  [Dropover](https://dropoverapp.com/) via its documented
  `open -a Dropover -- <path>` terminal-import hook, creating a shelf (or
  adding to the frontmost one) with it. Works for any kind.
- The menu bar icon (⛩) lists every portal with Open/Copy submenu items, as
  a mouse-driven mirror of `o`/`c`.

## Dropover integration

Two directions, both riding Dropover's own documented automation surface
(see [dropoverapp.com/tips](https://dropoverapp.com/tips), tips #4/#5/#14) —
nothing unofficial or UI-scripted:

- **Portal → shelf**: press `s` in Portal's modal (see above). Uses
  `open -a Dropover -- <path>`, Dropover's terminal-import hook.
- **Shelf → Portal**: [dropover-send-to-portal.sh](dropover-send-to-portal.sh)
  is a Dropover "Custom Script" — Dropover invokes shell scripts with the
  shelf's file paths as plain arguments, so this one forwards them (via a
  temp file, to dodge shell/Lua quoting) to
  `spoon.Portal:receiveFromShelf(...)` over the Hammerspoon CLI (`hs -c`,
  needs `require("hs.ipc")` in your `init.lua` — already there if you're
  using this repo's sibling Spoons). That opens a fuzzy chooser over every
  saved *directory* portal; Enter `mv`s the shelf's items there, or hold
  shift to `cp` instead.

  To install, run:

  ```sh
  ./setup-dropover.sh
  ```

  This copies the script into Dropover's sandboxed Application Scripts
  folder (`~/Library/Application Scripts/me.damir.dropover-mac`) and checks
  the `hs` CLI is on `PATH` — a symlink doesn't work here, Dropover's Custom
  Scripts import dialog can't resolve one pointing outside its own
  container, so re-run this script after editing
  `dropover-send-to-portal.sh` to pick up changes. Copying alone isn't
  enough either, though — Dropover only picks up a script once you import
  it through its own UI, which the script prints instructions for: Dropover
  Settings → Shelf Interaction → Advanced… → Custom scripts → Add (+) →
  pick `dropover-send-to-portal.sh` → leave "Script output" ignored. It
  then shows up in every shelf's Actions menu.

## Troubleshooting

If the leader key alert appears but subsequent keys (`a`, `o`, `c`, `d`, `s`)
don't seem to register and instead leak through to whatever app is focused,
check **System Settings → Privacy & Security → Input Monitoring** and make
sure Hammerspoon is listed there and enabled (this is separate from
Accessibility). If you just added it, **fully restart macOS** — a simple
relaunch of Hammerspoon.app is not enough for this permission to take effect.

If that's already granted, check for other global keyboard/automation tools
that might be capturing the same keys first — Karabiner-Elements, Raycast,
Alfred, Rectangle, Magnet, or similar. Try quitting them one at a time to
isolate the culprit, or reassign `Leader.spoon`'s leader combo (see
`hammerspoon-leader`'s `bindLeaderKey` call in `init.lua`) to one they
don't use.

## Design notes / open questions carried over from the handover doc

- **Copy default** — file object, per above, with the shift toggle rather
  than a separate keybinding, to keep the chooser flow to one keystroke for
  the common case.
- **Directories on open** — reveals in Finder (`open <dir>`) rather than
  `cd`-ing into a terminal. A terminal-cd path is a reasonable follow-up but
  would tie this Spoon to a specific terminal app.
- **Kind on add** — auto-detected from the path, never prompted (see M2
  above).
