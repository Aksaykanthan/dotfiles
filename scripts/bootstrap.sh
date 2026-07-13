#!/bin/bash
# One-shot bootstrap for a brand-new Mac.
#   curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/scripts/bootstrap.sh | bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "==> Installing chezmoi..."
  brew install chezmoi
fi

REPO="${DOTFILES_REPO:-git@github.com:<you>/dotfiles.git}"
echo "==> chezmoi init --apply $REPO"
chezmoi init --apply "$REPO"

echo
echo "Bootstrap complete. Optional manual steps:"
echo "  scripts/macos-touch-id-sudo.sh    # Touch ID for sudo"
echo "  scripts/restore-gui-prefs.sh      # Raycast/Shottr/Amphetamine/boringNotch/IINA prefs"
echo "  System Settings > Displays        # pick a 'More Space' scaled resolution (per-display, manual)"
