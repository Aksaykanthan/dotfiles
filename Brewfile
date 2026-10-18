# ---------------------------------------------------------------------------
# Brewfile — the "install" layer.
# Applied by home/.chezmoiscripts/run_once_before_10-brew-bundle.sh.tmpl
# Regenerate the installed-package section with: brew bundle dump --force
# ---------------------------------------------------------------------------

# ---- Taps ----
tap "gantoreno/macfetch"  # third-party tap for the macfetch formula below

# ---- CLI tools (formerly `brew leaves`) ----
brew "ansible"
brew "atuin"             # shell history search (Ctrl+R, Up arrow)
brew "bat"               # cat with syntax highlighting, used as the manpager below
brew "blueutil"          # used by ~/.wakeup and ~/.sleep
brew "btop"
brew "carapace"          # universal multi-shell completion generator
brew "cloudflared"
brew "eza"
brew "ffmpeg"
brew "fzf"
brew "gh"
brew "gh-dash"
brew "git-delta"         # `delta`: syntax-highlighted git diffs (core.pager, lazygit)
brew "herdr"             # agent multiplexer TUI for terminal
brew "macfetch"          # neofetch-style system summary, shown at login (see fish_greeting)
brew "neovim"
# LazyVim external tools (see `:checkhealth lazyvim snacks`)
brew "ast-grep"          # structural search/replace for grug-far
brew "fd"                # file finder for Snacks picker/explorer
brew "ghostscript"       # `gs`: PDF rendering in Snacks image
brew "imagemagick"       # image conversion for Snacks image
brew "lazygit"           # <leader>gg
brew "mermaid-cli"       # `mmdc`: Mermaid diagrams in markdown
brew "tectonic"          # LaTeX math rendering in markdown
brew "tree-sitter-cli"   # builds nvim-treesitter parsers
brew "node@24"
brew "openfortivpn"
brew "ripgrep"
brew "rtk"               # CLI proxy that compresses dev-command output before it reaches an AI agent's context; wired into omp via home/config-src/agents/omp/extensions/rtk-rewrite.ts
brew "sleepwatcher"      # runs ~/.wakeup and ~/.sleep, see macos/scripts layer
brew "k9s"
brew "television"        # `tv` — general-purpose fuzzy finder TUI
brew "tesseract"
brew "tree"
brew "whisper-cpp"
brew "worktrunk"         # `wt` - git worktree manager for parallel AI-agent branches
brew "yazi"
brew "zellij"            # terminal multiplexer
brew "zoxide"

# ---- Shell / prompt ----
brew "fish"
brew "oh-my-posh"        # replaces powerlevel10k

# ---- Language toolchains ----
brew "python@3.13"
brew "go"
brew "rust"              # if you already manage Rust via rustup, `brew unlink rust` after install
brew "node"
brew "bun"
brew "uv"

# ---- Fonts ----
cask "font-jetbrains-mono-nerd-font"

# ---- GUI apps ----
cask "amphetamine"
cask "beekeeper-studio"
cask "brave-browser"
cask "claude"
cask "codex"
cask "ghostty"
cask "iina"
cask "localsend"
cask "obsidian"
cask "orbstack"
cask "raycast"
cask "shottr"
cask "supacode"
cask "tigervnc"
cask "whatsapp"
cask "zed"
cask "zen-browser"

# ---- Not on Homebrew — install manually ----
# - boringNotch:            https://github.com/TheBoredTeam/boring-notch/releases
# - VS Code Insiders:       https://code.visualstudio.com/insiders (cask "visual-studio-code" installs stable only)
# - Raycast Beta:           join the beta channel from within Raycast > Preferences > Advanced
# - Headroom:                https://github.com/gglucass/headroom-desktop/releases/latest (paid subscription app;
#                             signup/plan selection is a manual step inside the app. Supports Claude Code + Codex
#                             only today, no omp/Pi integration — see its README's client support note.)
