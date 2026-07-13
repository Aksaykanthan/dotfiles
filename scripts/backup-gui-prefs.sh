#!/bin/bash
# Snapshots macOS `defaults` domains for GUI apps that have no config file
# of their own, as readable XML plists, into the macos/prefs layer.
# Run manually whenever you've tweaked one of these apps and want the
# dotfiles to remember it. Read-only w.r.t. the apps themselves.
set -euo pipefail

cd "$(dirname "$0")/.."
DEST="home/config-src/macos/prefs"
mkdir -p "$DEST"

declare -A DOMAINS=(
  [shottr]="cc.ffitch.shottr"
  [amphetamine]="com.if.Amphetamine"
  [boringnotch]="theboringteam.boringnotch"
  [iina]="com.colliderli.iina"
  [raycast]="com.raycast-x.macos"
)

for name in "${!DOMAINS[@]}"; do
  domain="${DOMAINS[$name]}"
  echo "==> Exporting $domain -> $DEST/$name.plist"
  defaults export "$domain" - 2>/dev/null | plutil -convert xml1 -o "$DEST/$name.plist" - || \
    echo "    (skipped: $domain has no preferences yet)"
done

echo "Done. Review the diff with 'git -C \"$(pwd)\" diff' before committing."
