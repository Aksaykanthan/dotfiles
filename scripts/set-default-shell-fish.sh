#!/bin/bash
# Registers Homebrew's fish in /etc/shells (requires sudo) and makes it the
# account's default login shell (requires the account password via chsh).
# Both steps need an interactive terminal, so this is a manual, one-time step
# run after `chezmoi apply` has installed fish via the Brewfile. Idempotent.
set -euo pipefail

FISH_BIN="$(command -v fish || true)"
if [ -z "$FISH_BIN" ]; then
  echo "error: fish not found on PATH. Run 'chezmoi apply' (installs it via the Brewfile) first." >&2
  exit 1
fi

if ! grep -qxF "$FISH_BIN" /etc/shells; then
  echo "==> Adding $FISH_BIN to /etc/shells (requires sudo)"
  echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
fi

if [ "${SHELL:-}" = "$FISH_BIN" ]; then
  echo "fish is already the default shell."
  exit 0
fi

echo "==> chsh -s $FISH_BIN (enter your account password if prompted)"
chsh -s "$FISH_BIN"
echo "Default shell set to fish. Open a new terminal tab to pick it up."
