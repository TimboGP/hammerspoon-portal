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

# Dropover runs Custom Scripts with a stripped-down PATH (confirmed against
# the real app - `hs` on PATH in an interactive shell still came back
# "command not found" here), so `hs` is located explicitly instead of
# relying on PATH the way the rest of this repo does.
HS_BIN=""
for candidate in /opt/homebrew/bin/hs /usr/local/bin/hs; do
  if [ -x "$candidate" ]; then
    HS_BIN="$candidate"
    break
  fi
done
if [ -z "$HS_BIN" ]; then
  echo "hs CLI not found at /opt/homebrew/bin/hs or /usr/local/bin/hs - run hs.ipc.cliInstall() in Hammerspoon's console" >&2
  exit 1
fi

tmp=$(mktemp /tmp/dropover-portal-XXXXXX)
trap 'rm -f "$tmp"' EXIT
printf '%s\n' "$@" > "$tmp"

"$HS_BIN" -c "spoon.Portal:receiveFromShelf(io.open('$tmp', 'r'):read('*a'))"
