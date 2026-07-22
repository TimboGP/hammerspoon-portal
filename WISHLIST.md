# hammerspoon-portal wishlist

Features discussed and deliberately deferred rather than built. Preserved
here as concrete specs so they can be picked up without re-deriving the
design.

---

## Cloud directories as a curated list of marked locations

Today `a` (add) only ever captures *ad hoc*: whatever's selected in
Finder, the frontmost app's bundle, or a manually-typed path (see
`capture.lua`, README's M2). There's no quick way to portal-ify the
handful of well-known cloud-sync root folders (iCloud Drive, Dropbox,
Google Drive, OneDrive, ...) short of navigating to each one in Finder
first and selecting it there.

Add a second, static capture source: a curated list of recognized
cloud-storage roots, filtered down to whichever actually exist on this
machine, offered as a fuzzy-pickable list of one-shot add candidates.

Approach:

- `capture.lua` gains `M.cloudDirectories()`, returning a `{name, path,
  kind = "directory"}` candidate for every entry in a small hardcoded
  table of well-known roots whose path exists on disk (`hs.fs.attributes`
  check, same as `classify`/`fromManualPath` already do) — e.g.:

  ```lua
  local CLOUD_ROOTS = {
    { name = "iCloud Drive", path = "~/Library/Mobile Documents/com~apple~CloudDocs" },
    { name = "Dropbox",      path = "~/Dropbox" },
    { name = "Google Drive", path = "~/Google Drive" },
    { name = "OneDrive",     path = "~/OneDrive" },
  }
  ```

  Not discovered dynamically (no reliable API for "which cloud providers
  are installed") — just a short list that's easy to extend by hand as new
  providers come up.
- Wire a new modal binding (free key, e.g. shift+`a`) that runs
  `chooser.pick(capture.cloudDirectories(), "Portal: add cloud directory",
  ...)` and feeds the selection through the existing `addCandidate` (name
  prompt, then `store.add`) — no new save path needed, just a new capture
  source ahead of the manual-path fallback.
- If none of the roots exist, alert "no cloud directories found on this
  Mac" and do nothing (mirrors `chooser.pick`'s empty-list handling).

Scope decisions:

- Root folders only, not a recursive browse of their contents — same
  explicit-add philosophy as the rest of Portal (see shortcut-system.md's
  "o domain detail": "explicit-add only, no filesystem-wide fuzzy
  search").
- No provider-specific behavior (no querying Dropbox's API for
  online-only/offline file state, etc.) — a cloud root is just a
  directory portal like any other once added; `open`/`copy`/`flatten` all
  already work on it unchanged.
