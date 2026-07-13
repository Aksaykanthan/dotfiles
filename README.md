# dotfiles

Managed with [chezmoi](https://chezmoi.io). One command reproduces this whole
Mac: shell, terminal, editors, CLI tools, AI agent tooling, and the macOS
system layer.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/<you>/dotfiles/main/scripts/bootstrap.sh)"
```

## Layout

```
dotfiles/                    repo root — NOT mirrored into $HOME (see .chezmoiroot)
├── .chezmoiroot             -> "home"  (chezmoi's real source root is home/)
├── Brewfile                 install layer: taps, formulae, casks
├── scripts/                 one-off / manual maintenance scripts (not auto-run)
└── home/                    chezmoi source root, mirrors $HOME
    ├── .chezmoiignore       keeps config-src/ out of the deployed tree
    ├── .chezmoiremove       retires powerlevel10k leftovers on `apply`
    ├── .chezmoiexternal.yaml  nvim = a real `git-repo` clone of LazyVim/starter
    ├── .chezmoiscripts/     ordered run_once_ hooks (install layer automation)
    ├── config-src/          the real, editable files — organised by layer
    │   ├── shell/           zsh, oh-my-posh
    │   ├── git/
    │   ├── terminal/ghostty/
    │   ├── editors/         zed, vscode (nvim lives outside config-src, see below)
    │   ├── cli/              btop, gh, gh-dash, k9s
    │   ├── agents/           claude, codex, omp (this harness)
    │   └── macos/            wakeup/sleep scripts, GUI-app defaults() snapshots
    └── symlink_* / dot_*/…  thin stubs chezmoi materialises into $HOME
```

`~/.config/nvim` is the one exception to the symlink-into-config-src pattern:
it's a real `git clone` of `LazyVim/starter` (`.chezmoiexternal.yaml`, type
`git-repo`), refreshed every 168h by `chezmoi apply`/`chezmoi update` — exactly
`git clone https://github.com/LazyVim/starter ~/.config/nvim`, just kept in
sync automatically. Customize it in place; it's its own git working tree, so
commit your changes there directly (fork the starter repo first if you want
`git pull` to bring in only upstream changes cleanly).

**Every managed dotfile in `$HOME` is a real symlink into `config-src/`.**
`chezmoi apply` only ever (re)creates the symlink; edit the file directly
wherever it lives (`~/.zshrc`, `~/.config/nvim`, etc.) and the change is
already live — no `chezmoi apply` round-trip needed. Run `chezmoi re-add` to
pull edits back into a `chezmoi diff`-able commit when you're ready.

Why the `config-src/` indirection instead of `symlink_dot_config/nvim`
pointing straight at itself? Because a chezmoi target path can't be both the
managed symlink *and* the real content — `config-src` is `.chezmoiignore`d
(never deployed on its own) but still lives on disk as part of the git
checkout, so `{{ .chezmoi.sourceDir }}/config-src/...` is a stable target for
every symlink stub.

## Layers, in apply order

1. **Homebrew** (`.chezmoiscripts/run_once_before_00…`) — installs Homebrew
   itself if missing.
2. **Brewfile** (`run_once_before_10…`) — `brew bundle`: CLI tools, language
   toolchains (python, go, rust, node, bun, uv, ansible), fonts, GUI app
   casks.
3. **Dotfiles** — chezmoi's normal file/symlink pass, plus the `nvim`
   `git-repo` external. Shell (`.zshrc` / `.zprofile` / `.zshenv` +
   oh-my-posh), git, ghostty, zed, VS Code settings, btop, gh/gh-dash, k9s
   (transparent skin), and the Claude / Codex / omp agent configs.
4. **Permissions** (`run_once_after_20…`) — `chmod +x` on `~/.wakeup` /
   `~/.sleep`, starts the `sleepwatcher` brew service that runs them.
5. **nvim plugin sync** (`run_once_after_25…`) — headless `Lazy! sync` so
   the first real `nvim` launch isn't slow/interactive.
6. **VS Code extensions** (`run_once_after_30…`) — installs everything in
   `config-src/editors/vscode/extensions.txt`.
7. **macOS defaults** (`run_once_after_40…`) — tap-to-click, dark appearance
   with tinted-dark icons/widgets, creates `~/Pictures/Wallpapers`.

`run_once_*` scripts only run once per machine (chezmoi tracks a hash of
each script); re-run any of them with `chezmoi state delete-bucket
--bucket=scriptState` if you need to force a re-run.

## Manual steps (deliberately not automated)

- **Touch ID for sudo** — `scripts/macos-touch-id-sudo.sh` (needs `sudo`,
  writes `/etc/pam.d/sudo_local`).
- **GUI app preferences** (Raycast, Shottr, Amphetamine, boringNotch, IINA)
  — snapshotted as readable XML plists under `config-src/macos/prefs/`.
  `scripts/backup-gui-prefs.sh` re-exports them after you tweak an app;
  `scripts/restore-gui-prefs.sh` imports them on a new Mac. Not run by
  `chezmoi apply` because these change via normal app usage constantly and
  would otherwise fight with a scripted overwrite on every apply.
- **Displays → "More Space" scaled resolution** — stored per-display by
  hardware UUID in `com.apple.windowserver.displays.plist`; there's no
  portable `defaults write` for it. Toggle it once in System Settings.
- **Raycast Beta channel** — Raycast Preferences → Advanced → Beta Updates.
- **VS Code Insiders / boringNotch** — not on Homebrew; see the comment
  block at the bottom of `Brewfile`.

## Apps installed but not config-managed

Brave, Zen, WhatsApp, Beekeeper Studio, Obsidian, and Supacode store dense,
per-machine application state (SQLite/LevelDB caches, per-repo worktree
scripts, vault paths) rather than portable config. They're installed via the
Brewfile; their state is intentionally left to the app's own sync/backup.

## Replacing powerlevel10k

`config-src/shell/oh-my-posh.yaml` is the new prompt, wired up at the bottom
of `config-src/shell/zshrc`. `.chezmoiremove` deletes `~/.p10k.zsh` and its
instant-prompt caches the next time you run `chezmoi apply`.

## Common commands

```sh
chezmoi diff                 # see what would change
chezmoi apply                # apply the full layered stack
chezmoi apply --exclude=scripts   # dotfiles only, skip install/system scripts
chezmoi re-add                    # pull hand-edited config-src/ changes back
chezmoi cd && git add -A && git commit   # commit from the source dir
```

## Verifying the setup works

Fast, non-destructive checks, in order:

```sh
# 1. Source tree is internally consistent (no bad targets, unresolved
#    templates, syntax errors) — catches most authoring mistakes.
chezmoi verify
chezmoi doctor            # look for any `error`/`fail` rows

# 2. See exactly what would change before touching anything.
chezmoi diff

# 3. Apply just the dotfile/symlink layer (safe, no installs).
chezmoi apply --exclude=scripts
chezmoi status             # should print nothing once applied

# 4. Confirm the symlinks are real and point where they should.
readlink ~/.zshrc ~/.gitconfig ~/.config/oh-my-posh/config.yaml
readlink "$HOME/Library/Application Support/k9s/config.yaml"

# 5. Shell loads without errors and the new bits are wired up.
zsh -n ~/.zshrc                       # syntax check only, no side effects
zsh -i -c 'exit'                      # full interactive load; watch for errors
zsh -i -c 'type k9s docker kubectl'   # docker/kubectl snippets + k9s alias

# 6. nvim: confirm the LazyVim clone landed and plugins install cleanly.
git -C ~/.config/nvim remote -v       # should be LazyVim/starter
nvim --headless "+Lazy! sync" +qa && echo nvim-ok

# 7. k9s: confirm it parses the config/skin (no cluster needed).
k9s info                              # should list config.yaml + skins with no parse errors

# 8. git aliases resolve.
git lg -3   # or: git co, git st, git undo, git sync

# 9. Run the install-layer scripts only when you actually want brew/vscode/
#    macOS-defaults changes applied (they're the parts that touch more than
#    dotfiles):
chezmoi apply
```

If anything looks wrong, `chezmoi diff` again before reapplying — it always
shows the exact change, never applies silently.
