# My dotfiles

My personal macOS configuration, managed with [chezmoi](https://chezmoi.io).

## What's managed

- Shell: fish with vi key bindings, a minimal no-background oh-my-posh
  prompt, and a macfetch system summary at login
- Terminal: Ghostty (Alt+V for a Vim-style scrollback key table), with
  zellij as the multiplexer inside it. Everything is Catppuccin Mocha,
  styled after DevOps Toolbox (omerxx/dotfiles) — see "Zellij" below
- Vim mode everywhere: fish, Claude Code (`editorMode`), Codex
  (`[tui] vim_mode_default`), atuin (`keymap_mode = "auto"`), btop
  (`vim_keys`), readline (`~/.inputrc`) and libedit (`~/.editrc`) REPLs,
  Zed. omp has no vim mode; `$EDITOR=nvim` makes its Ctrl+G (and Claude
  Code's) open the prompt in nvim
- Wallpapers: a pinned Catppuccin set fetched into
  `~/Pictures/Wallpapers/catppuccin` by a one-time hook; `wall`, `wall
  random`, `wall <name>`, `wall ls` switch between them
- Editors: LazyVim, Zed, VS Code settings and extensions
- CLI: git, gh, gh-dash, btop, k9s, atuin, carapace, television (`tv`), worktrunk (`wt`), zoxide, ripgrep, bat, macfetch
- AI tools: Claude, Codex, Oh My Pi (`omp`, installed globally via `bun install
  -g @oh-my-pi/pi-coding-agent`; its `config.yml` and MCP server registry
  `mcp.json` are both chezmoi-managed, see below)
- Token-optimization tools for AI coding agents: `rtk` (CLI output
  compression, wired into omp as a native hook — see below), `caveman`
  (terse-output mode, wired into omp as a native hook), `pxpipe` (Anthropic
  request compression, run as a LaunchAgent proxy omp routes through),
  Headroom (Claude Code/Codex only, installed manually — no omp
  integration exists upstream)
- macOS: `.wakeup`, `.sleep`, selected app preferences, and safe defaults
- Packages and apps: `Brewfile`

Most managed configuration files are symlinks into
`home/config-src/`. Edit either the live file (for example `~/.config/fish/config.fish`) or its
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

## Zellij

`config-src/terminal/zellij/` holds the config, a `devops` layout with a
zjstatus bar on top (session · tabs · mode · git branch · dir · clock),
its swap layouts, and the `devops-mocha` theme (Catppuccin Mocha with a
mauve active-pane frame). Plugins are pinned release URLs that Zellij
downloads on first use: zjstatus, zellij-autolock, zsm, room, forgot.

Keys (stock bindings are cleared):

| Keys | Action |
| :- | :- |
| `Alt h/j/k/l` | move focus (h/l cross into the next tab) — works everywhere, even inside nvim/Claude |
| `Alt n` · `Alt w` · `Alt e` · `Alt z` | new pane · toggle floating · float/embed · fullscreen |
| `Alt 1-9` · `Alt [ ]` · `Alt = -` | go to tab · swap layout · resize |
| `Alt s` · `Alt g` · `Alt ?` | sessions (zsm) · fuzzy tab picker (room) · key cheat sheet |
| `Alt .` · `Alt Shift .` | toggle lock by hand · toggle autolock |
| `Ctrl a` then `\|` `-` `c` `,` `n` `b` `x` `z` `p` `r` `m` `[` `/` `s` `d` | tmux-style prefix: split right/down, new/rename/next/prev tab, close, zoom, floating, resize/move/scroll/search mode, sessions, detach |

autolock switches Zellij to Locked whenever the focused pane runs anything
but the shell, so Ctrl keys reach nvim, fzf, Claude Code, omp, k9s, ...
untouched; only `Alt` keys stay with Zellij. Option+Left/Right are left to
the shell as word jumps.

## Personal settings

`home/.chezmoidata.yaml` is the commented catalog for personal and
machine-specific, non-secret values: identity, GitHub, Git, shell, editors,
terminal, Homebrew, macOS, CLI tools, languages, AI tools, and common paths.

```sh
zed "$HOME/development/dotfiles/home/.chezmoidata.yaml"
chezmoi apply ~/.gitconfig
```

Git name and email are rendered into `~/.gitconfig`. Its GitHub username and
protocol are derived from `config-src/cli/gh/hosts.yml`, the config maintained
by `gh auth login`. Never store tokens, passwords, API keys, or private keys
in this repository.

For a path inside a template, use `{{ .chezmoi.homeDir }}` or a value from
`.chezmoidata.yaml`; never hardcode `/Users/<name>`. The Codex configuration
uses this pattern and is rendered by chezmoi rather than symlinked.

## Oh My Pi MCP servers

`home/config-src/agents/omp/mcp.json` (symlinked to `~/.omp/agent/mcp.json`)
registers MCP servers for `omp`. It never contains raw credentials — server
`env` blocks reference environment variable *names* (e.g. `OVERLEAF_SESSION`)
that `omp` resolves at connect time from the shell environment. The actual
secret values live in `~/.config/fish/conf.d/secrets.fish`, a local file that
is deliberately **not** chezmoi-managed and **not** committed here — fish
auto-sources `conf.d/*.fish`, and `~/.config/fish/conf.d/` only has
`config.fish` under chezmoi's control, so anything else placed there is
machine-local by construction. Recreate that file by hand on a new machine:

```fish
# ~/.config/fish/conf.d/secrets.fish  (chmod 600, never committed)
set -gx OVERLEAF_SESSION "..."
set -gx OVERLEAF_GIT_TOKEN "..."
```

## Token-optimization tools for AI agents

Four tools that reduce the token cost of driving an AI coding agent. All
four were installed and wired in with the understanding that they sit
between the agent and the model — they can see and modify prompts, tool
output, or both. None of them phone home beyond the model API itself
(verified from each project's own source/docs before installing), but that
design is inherent to what they do, not a side effect.

**rtk** (`brew "rtk"`) compresses verbose CLI output (git, test runners,
etc.) before it reaches the agent's context. It ships hooks for several
agents but has no `omp`/Pi target — its Claude Code hook relies on rewriting
the tool call in place, which omp's hook API does not expose (`tool_call`
can only block/allow, never mutate the input; see `hooks.md` in the omp
docs). `home/config-src/agents/omp/extensions/rtk-rewrite.ts` is the native
equivalent: it shells out to `rtk rewrite <cmd>` (rtk's own single source of
truth for the mapping — never duplicated here) and, when a compressed
equivalent exists, blocks the raw command with the rewrite as the reason, so
the agent retries with it. Self-correcting, not a silent rewrite.

**caveman** (github.com/JuliusBrussee/caveman) makes the agent respond in
terse, compressed prose. Also has no omp/Pi entry in its own agent matrix.
`home/config-src/agents/omp/extensions/caveman.ts` injects its activation
rule (copied verbatim from `src/rules/caveman-activate.md` upstream) once
per session via omp's `before_agent_start` hook — the native equivalent of
the SessionStart hook caveman uses on Claude Code. The `/caveman-compress`
memory-file-compression skill was **not** wired in; it vendors caveman's own
Python scripts and an Anthropic API call, out of scope here.

**pxpipe** (`pxpipe-proxy` on npm, `bun add -g`) renders bulky Anthropic
request context (system prompt, tool docs, old history) as PNG pages —
images are billed by pixel dimensions, not text length, so dense content
costs fewer tokens. Runs as a LaunchAgent
(`Library/LaunchAgents/dev.pxpipe.proxy.plist.tmpl`, `RunAtLoad` +
`KeepAlive`, so it survives reboots and crashes) listening on
`127.0.0.1:47821`. omp is pointed at it via `ANTHROPIC_BASE_URL` in
`~/.omp/agent/.env` (`home/config-src/agents/omp/env`) — scoped to omp only
through `.env` file precedence, not a shell-wide export, so Claude Code /
Claude Desktop / anything else on the machine still talks to Anthropic
directly. It is lossy on byte-exact content (hex strings, hashes); see
pxpipe's own `docs/NOT-OCR.md` before relying on it for anything precision
-critical.

**Headroom** (github.com/gglucass/headroom-desktop, installed manually — see
Brewfile) is a **paid** menu-bar app bundling its own optimization pipeline
plus rtk. Its own README states it supports Claude Code and Codex only — no
omp/Pi integration exists upstream, and none was built here. Installed for
completeness since it was requested; account signup and plan selection are
manual steps inside the app that couldn't be completed on your behalf.

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
fish -n ~/.config/fish/config.fish
fish -c 'type oh-my-posh'
oh-my-posh print primary --config ~/.config/oh-my-posh/config.yaml

# Editors.
zed .
git -C ~/.config/nvim remote get-url origin
nvim --headless "+Lazy! sync" +qa

# Managed CLI configuration.
k9s info
git lg -3

# Terminal multiplexer.
zellij setup --check
```

## Manual actions

```sh
# Enable Touch ID for sudo. Requires an administrator password.
scripts/macos-touch-id-sudo.sh

# Make fish the default login shell. Requires sudo and the account password.
scripts/set-default-shell-fish.sh

# Save or restore Raycast, Shottr, Amphetamine, boringNotch, and IINA preferences.
scripts/backup-gui-prefs.sh
scripts/restore-gui-prefs.sh
```

Brave, Zen, WhatsApp, Beekeeper Studio, Obsidian, and Supacode are installed
through the Brewfile, but their machine-specific application databases are not
managed here.
