#!/bin/bash
# Imports the macos/prefs plist snapshots back into `defaults` on a new Mac.
# Restart each app (or the whole session) afterwards to pick the prefs up.
# Not run automatically by chezmoi — GUI-app prefs change too often to
# force on every `chezmoi apply`; run this once, deliberately, per machine.
set -euo pipefail

cd "$(dirname "$0")/.."
SRC="home/config-src/macos/prefs"

declare -A DOMAINS=(
  [shottr]="cc.ffitch.shottr"
  [amphetamine]="com.if.Amphetamine"
  [boringnotch]="theboringteam.boringnotch"
  [iina]="com.colliderli.iina"
  [raycast]="com.raycast-x.macos"
)

for name in "${!DOMAINS[@]}"; do
  plist="$SRC/$name.plist"
  domain="${DOMAINS[$name]}"
  if [ -f "$plist" ]; then
    echo "==> Importing $plist -> $domain"
    defaults import "$domain" "$plist"
  fi
done

echo "Done. Quit and relaunch the affected apps."
