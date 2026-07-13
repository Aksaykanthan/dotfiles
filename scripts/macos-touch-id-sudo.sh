#!/bin/bash
# Enables Touch ID for `sudo` via /etc/pam.d/sudo_local, the update-safe
# mechanism introduced in macOS Sonoma. Requires sudo. Idempotent.
set -euo pipefail

TEMPLATE="/etc/pam.d/sudo_local.template"
TARGET="/etc/pam.d/sudo_local"

if [ ! -f "$TEMPLATE" ]; then
  echo "error: $TEMPLATE not found (macOS Sonoma+ only)" >&2
  exit 1
fi

if [ -f "$TARGET" ] && grep -q '^auth\s\+sufficient\s\+pam_tid.so' "$TARGET"; then
  echo "Touch ID for sudo already enabled."
  exit 0
fi

sudo cp "$TEMPLATE" "$TARGET"
sudo sed -i '' 's/^#auth       sufficient     pam_tid.so/auth       sufficient     pam_tid.so/' "$TARGET"
echo "Touch ID for sudo enabled. Open a new terminal tab to pick it up."
