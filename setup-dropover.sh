#!/usr/bin/env bash
# setup-dropover.sh — wire dropover-send-to-portal.sh into Dropover.
#
# Safe to re-run: every step is idempotent.
set -euo pipefail

# -P resolves symlinks physically, same reasoning as the sibling Spoons'
# install.sh: running this through a Spoons/Portal.spoon convenience
# symlink shouldn't resolve REPO_DIR to that symlink's own path.
REPO_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Dropover's sandboxed "Application Scripts" container - the only place it
# will import a Custom Script from (see the README's Dropover integration
# section, and https://dropoverapp.com/kb/application-scripts).
DROPOVER_SCRIPTS_DIR="$HOME/Library/Application Scripts/me.damir.dropover-mac"

echo "== hammerspoon-portal: Dropover setup =="
echo "repo: $REPO_DIR"

# --- 1. Dropover installed? ----------------------------------------------
if [ ! -d "$DROPOVER_SCRIPTS_DIR" ]; then
  echo "[!!] $DROPOVER_SCRIPTS_DIR not found."
  echo "     Install and launch Dropover at least once (its sandbox"
  echo "     container is created on first run), then re-run this script."
  exit 1
fi
echo "[ok] Dropover Application Scripts folder found"

# --- 2. Symlink the script in ---------------------------------------------
ln -sfn "$REPO_DIR/dropover-send-to-portal.sh" "$DROPOVER_SCRIPTS_DIR/dropover-send-to-portal.sh"
echo "[ok] symlinked as $DROPOVER_SCRIPTS_DIR/dropover-send-to-portal.sh"

# --- 3. hs CLI --------------------------------------------------------------
# Checked via PATH, not hs.ipc.cliStatus() - same reasoning as instantvim's
# install.sh: cliStatus() only checks its default /usr/local/bin/hs location,
# a false negative on Apple Silicon + Homebrew where `hs` is on PATH via
# /opt/homebrew/bin/hs instead. The script this sets up depends on `hs` -c
# being reachable, same as Portal's own dependency on it.
if command -v hs >/dev/null 2>&1; then
  echo "[ok] 'hs' CLI found on PATH ($(command -v hs))"
else
  echo "[!!] 'hs' CLI not found on PATH."
  echo "     Open Hammerspoon and run in its console: hs.ipc.cliInstall()"
  echo "     Then re-run this script."
fi

# --- 4. Manual steps still required ----------------------------------------
cat <<EOF

== Remaining manual steps ==

Dropover only picks up scripts from its Application Scripts folder once
you import them through its own UI - symlinking the file in isn't enough:

1. Open Dropover Settings -> Shelf Interaction -> Advanced... -> Custom
   scripts.
2. Click "+" / Add, and select "dropover-send-to-portal.sh" (it should now
   show up in that folder's file picker).
3. Leave "Script output" as ignored - the script talks to Portal directly
   and doesn't produce anything Dropover needs to handle.
4. Optionally click "Run Test..." and pick a sample file to confirm it
   works: Portal's own chooser should pop up over your saved directory
   portals.

It'll then appear in every shelf's Actions menu as "dropover-send-to-portal"
(rename it from that same screen if you want a friendlier label).

EOF
