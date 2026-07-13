# My dotfiles

My personal macOS configuration, managed with [chezmoi](https://chezmoi.io).

## What's managed

- Shell: zsh and a minimal, no-background oh-my-posh prompt
- Terminal: Ghostty
- Editors: LazyVim, Zed, VS Code settings and extensions
- CLI: git, gh, gh-dash, btop, k9s
- AI tools: Claude, Codex, Oh My Pi
- macOS: `.wakeup`, `.sleep`, selected app preferences, and safe defaults
- Packages and apps: `Brewfile`

Most managed configuration files are symlinks into
`home/config-src/`. Edit either the live file (for example `~/.zshrc`) or its
source file; the change is live immediately.

`~/.config/nvim` is different: chezmoi clones
[LazyVim/starter](https://github.com/LazyVim/starter) there as its own Git
repository. Customize and commit it from that directory.

## Layout

```text
Brewfile                 Homebrew formulae, casks, and fonts
scripts/                 Manual maintenance scripts
home/
  .chezmoiscripts/       Ordered one-time setup hooks
  .chezmoiexternal.yaml  LazyVim Git clone definition
  .chezmoidata.yaml       Personal, non-secret template settings
  config-src/            Actual configuration files
```

## Personal settings

Edit `home/.chezmoidata.yaml` for settings that differ by person or machine:

```yaml
git:
  name: Your Name
  email: you@example.com
github:
  username: your-github-name
shell:
  editor: zed
  terminal: ghostty
```

Git reads the name and email from this file when `chezmoi apply` generates
`~/.gitconfig`. Do not store tokens, passwords, API keys, or private keys in
this repository.

## Setup

```sh
# Install chezmoi, then point it at this local checkout.
brew install chezmoi
chezmoi init --source "$HOME/development/dotfiles"

# Preview all changes first.
chezmoi diff

# Apply only files and symlinks. No package installs or macOS changes.
chezmoi apply --exclude=scripts

# Apply the complete machine setup, including the Brewfile and one-time hooks.
chezmoi apply
```

The full apply installs Homebrew packages, syncs LazyVim plugins, installs VS
Code extensions, enables the sleepwatcher service, and applies safe macOS
defaults.

## Daily commands

```sh
# See pending changes.
chezmoi status
chezmoi diff

# Apply configuration changes.
chezmoi apply --exclude=scripts

# Apply everything, including one-time setup scripts.
chezmoi apply

# Commit this repository.
cd "$HOME/development/dotfiles"
git add -A
git commit -m "describe the change"
```

## Checks

```sh
# A blank result with exit code 0 means the target matches chezmoi.
chezmoi verify

# Exit code 1 with no output means something is pending; identify it here.
chezmoi status

# Shell and prompt.
zsh -n ~/.zshrc
zsh -i -c 'type oh-my-posh'
oh-my-posh print primary --config ~/.config/oh-my-posh/config.yaml

# Editors.
zed .
git -C ~/.config/nvim remote get-url origin
nvim --headless "+Lazy! sync" +qa

# Managed CLI configuration.
k9s info
git lg -3
```

## Manual actions

```sh
# Enable Touch ID for sudo. Requires an administrator password.
scripts/macos-touch-id-sudo.sh

# Save or restore Raycast, Shottr, Amphetamine, boringNotch, and IINA preferences.
scripts/backup-gui-prefs.sh
scripts/restore-gui-prefs.sh
```

Brave, Zen, WhatsApp, Beekeeper Studio, Obsidian, and Supacode are installed
through the Brewfile, but their machine-specific application databases are not
managed here.
