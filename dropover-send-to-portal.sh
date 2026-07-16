#!/usr/bin/env bash
# Dropover "Custom Scripts" hook: import this into Dropover's Application
# Scripts folder (Settings -> Shelf Interaction -> Advanced... -> Custom
# scripts) and run it from a shelf's Actions menu. Dropover invokes shell
# scripts with the shelf's file paths as positional arguments; this
# forwards them to hammerspoon-portal's destination picker via the
# Hammerspoon CLI (`hs -c`, requires `require("hs.ipc")` in init.lua).
#
# Paths go through a temp file rather than straight into the `hs -c` Lua
# literal, so a path containing a quote or other shell/Lua-special
# character can't break the generated command.
set -euo pipefail

tmp=$(mktemp /tmp/dropover-portal-XXXXXX)
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$@" > "$tmp"

hs -c "spoon.Portal:receiveFromShelf(io.open('$tmp', 'r'):read('*a'))"
