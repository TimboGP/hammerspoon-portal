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

- Leader key: `cmd+ctrl+alt+p` (default, see `config.lua`). Press it to
  enter the modal; an alert confirms entry and lists the keys below. Press
  `esc`, or wait ~3.5s idle, to exit.
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
- The menu bar icon (⛩) lists every portal with Open/Copy submenu items, as
  a mouse-driven mirror of `o`/`c`.

## Design notes / open questions carried over from the handover doc

- **Copy default** — file object, per above, with the shift toggle rather
  than a separate keybinding, to keep the chooser flow to one keystroke for
  the common case.
- **Directories on open** — reveals in Finder (`open <dir>`) rather than
  `cd`-ing into a terminal. A terminal-cd path is a reasonable follow-up but
  would tie this Spoon to a specific terminal app.
- **Kind on add** — auto-detected from the path, never prompted (see M2
  above).
