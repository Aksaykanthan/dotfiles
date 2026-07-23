# ==============================================================
# fish ships autosuggestions, syntax highlighting, and a native
# completion pager out of the box - no zinit/fisher/plugin
# manager needed. Each CLI below ships or generates its own
# fish integration; anything without one falls back to carapace.
# ==============================================================

# --------------------------------------------------------------
# Vi key bindings + mode indicator
# --------------------------------------------------------------
set -g fish_key_bindings fish_vi_key_bindings

# Terminal cursor shape per vi mode (block/line/underscore via DECSCUSR).
set -g fish_cursor_default block
set -g fish_cursor_insert line
set -g fish_cursor_visual block
set -g fish_cursor_replace_one underscore

function fish_mode_prompt --description 'Vi mode indicator ahead of the oh-my-posh prompt'
    switch $fish_bind_mode
        case default
            set_color --bold red
            echo -n 'N '
        case replace_one replace
            set_color --bold yellow
            echo -n 'R '
        case visual visual_line
            set_color --bold magenta
            echo -n 'V '
        case '*'
            set_color --bold green
            echo -n 'I '
    end
    set_color normal
end

function __fish_prepend_sudo --description 'Alt+s: prepend sudo to the current/last command'
    set -l buf (commandline)
    if test -z "$buf"
        set buf (history --max=1)
    end
    if not string match -q 'sudo *' -- $buf
        set buf "sudo $buf"
    end
    commandline --replace -- $buf
    commandline -f end-of-line
end
bind -M insert \es __fish_prepend_sudo
bind -M default \es __fish_prepend_sudo

# --------------------------------------------------------------
# Syntax highlighting colors (Tokyo Night, matches the Ghostty
# theme). Known commands/builtins/functions stand out in bold
# green; anything fish can't resolve is bold red, so a typo is
# obvious before you hit enter.
# --------------------------------------------------------------
set -g fish_color_normal c0caf5
set -g fish_color_command 9ece6a --bold
set -g fish_color_keyword bb9af7 --bold
set -g fish_color_param c0caf5
set -g fish_color_option c0caf5
set -g fish_color_quote e0af68
set -g fish_color_redirection 7dcfff
set -g fish_color_end bb9af7
set -g fish_color_error f7768e --bold
set -g fish_color_comment 565f89 --italics
set -g fish_color_operator 7dcfff
set -g fish_color_escape ff9e64
set -g fish_color_autosuggestion 565f89
set -g fish_color_valid_path --underline
set -g fish_color_cwd 9ece6a
set -g fish_color_cwd_root f7768e
set -g fish_color_selection c0caf5 --bold --background=32344a
set -g fish_color_search_match --background=32344a
set -g fish_pager_color_prefix 7aa2f7 --bold
set -g fish_pager_color_completion c0caf5
set -g fish_pager_color_description 565f89
set -g fish_pager_color_selected_background --background=32344a

# --------------------------------------------------------------
# Greeting: swap the stock "Welcome to fish ... Type help ..."
# for a compact status line plus a rotating tip pulled from the
# tools this config already wires up.
# --------------------------------------------------------------
function fish_greeting
    set -l tips \
        "zoxide: 'cd foo' jumps to any visited dir by frecency" \
        "atuin: Ctrl+R searches synced, cross-machine shell history" \
        "fzf: Ctrl+T pastes a fuzzy-picked path, Alt+C fuzzy-cds" \
        "eza: 'ls' already shows icons, git status, long format" \
        "zellij: 'zj' attaches (or creates) the 'main' session" \
        "k9s: 'k' opens the Kubernetes dashboard" \
        "bat: 'cat' and man pages now have syntax highlighting" \
        "vi mode: Alt+s prepends sudo to the current/last command" \
        "yazi: 'l' opens a full-screen file manager right here"

    set -l uptime_str (uptime | string replace -r '.*up ' '' \
        | string replace -r ',?\s*\d+ users?.*' '' \
        | string replace -ra '\s+' ' ' | string trim)
    set -l os_version (sw_vers -productVersion 2>/dev/null)

    set_color --bold 7aa2f7
    echo -n (whoami)@(hostname -s)
    set_color 565f89
    echo -n '  ·  '(date '+%a %d %b, %H:%M')
    set_color normal
    echo

    set_color 9ece6a
    echo -n "macOS $os_version"
    set_color 565f89
    echo -n "  ·  fish $version  ·  up $uptime_str"
    set_color normal
    echo

    set_color bb9af7
    echo -n '› '
    set_color c0caf5
    echo $tips[(random 1 (count $tips))]
    set_color normal
end

# --------------------------------------------------------------
# Completion: carapace as a universal fallback completer.
# Native fish completions installed by Homebrew (gh, k9s,
# zoxide, rg, zellij, atuin, eza, ...) still take priority;
# this mainly covers docker/kubectl and everything else.
# --------------------------------------------------------------
if type -q carapace
    carapace _carapace fish | source
end

# --------------------------------------------------------------
# zoxide - smarter `cd`
# --------------------------------------------------------------
if type -q zoxide
    zoxide init --cmd cd fish | source
end

# --------------------------------------------------------------
# fzf key bindings (Ctrl+T paste path, Alt+C cd, ** completion).
# Ctrl+R is left to atuin, sourced after so its binding wins.
# --------------------------------------------------------------
if type -q fzf
    fzf --fish | source
end

# --------------------------------------------------------------
# atuin - searchable, synced shell history (Ctrl+R, Up arrow;
# vi-mode aware out of the box)
# --------------------------------------------------------------
if type -q atuin
    atuin init fish | source
end

# --------------------------------------------------------------
# Prompt: oh-my-posh
# --------------------------------------------------------------
if type -q oh-my-posh
    oh-my-posh init fish --config "$HOME/.config/oh-my-posh/config.yaml" | source
end

# --------------------------------------------------------------
# History
#   fish keeps its own history file; atuin (above) owns
#   interactive search across it, so there's no size to tune.
# --------------------------------------------------------------

# --------------------------------------------------------------
# Keybindings
# --------------------------------------------------------------
bind -M insert \cp history-prefix-search-backward
bind -M insert \cn history-prefix-search-forward

# --------------------------------------------------------------
# Aliases
#   git/docker/kubectl shell aliases dropped: git aliases live
#   in ~/.gitconfig (co, br, ci, st, lg, ...); docker/kubectl
#   completions come from carapace above.
# --------------------------------------------------------------
alias ls 'eza --long --group --group-directories-first --icons --header --time-style long-iso'
if type -q bat
    alias cat bat
end
alias vim nvim
alias c clear
alias bi 'brew install'
alias .. 'cd ..'
alias ... 'cd ../..'
alias l yazi
alias k k9s
alias zj 'zellij attach -c main'
test -f "$HOME/vnc.sh"
and alias vnc "bash $HOME/vnc.sh"

# --------------------------------------------------------------
# Environment variables
# --------------------------------------------------------------
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx TERM xterm-256color
set -gx CHROME_EXECUTABLE "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# bat - colorized `cat` (aliased above) and manpager
if type -q bat
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx MANROFFOPT '-c'
end

# cargo (was ~/.zshenv: `. "$HOME/.cargo/env"`)
fish_add_path -P "$HOME/.cargo/bin"

# OrbStack (was ~/.zprofile: `source ~/.orbstack/shell/init.zsh`)
test -f "$HOME/.orbstack/shell/init2.fish"
and source "$HOME/.orbstack/shell/init2.fish"

# Editor CLIs bundled with the installed applications, so `code` and
# `zed` are on PATH. VS Code's bin dir is prepended (it ships no other
# CLIs that would shadow something more important); Zed's is appended
# instead of prepended because Contents/MacOS also bundles its own
# `git`, and prepending it would shadow the real git (breaking
# `git push`/`fetch` with a missing git-remote-https error).
# fish_add_path silently skips paths that don't exist, so no
# extra existence guard is needed here.
fish_add_path -P "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
fish_add_path -P -a "/Applications/Zed.app/Contents/MacOS"

fish_add_path -P "$HOME/.antigravity-ide/antigravity-ide/bin"

set -gx PNPM_HOME "$HOME/Library/pnpm"
fish_add_path -P "$PNPM_HOME"
fish_add_path -P "$HOME/.local/bin"

# React Native / Android
set -gx JAVA_HOME (/usr/libexec/java_home 2>/dev/null)
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
fish_add_path -P -a "$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools"

# agam
fish_add_path -P "$HOME/coding/agam/.venv/bin"

# conda
if test -f "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
    source "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
else
    fish_add_path -P "$HOME/miniconda3/bin"
end

# bun
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -P "$BUN_INSTALL/bin"
if type -q bun
    # bun picks its completion dialect from $SHELL, not the caller;
    # pin it so this still works before `chsh -s fish` takes effect.
    env SHELL=fish bun completions 2>/dev/null | source
end

# omp (this harness's CLI)
if type -q omp
    omp completions fish | source
end

# ngrok
if type -q ngrok
    ngrok completion fish | source
end

# OpenClaw
test -f "$HOME/.openclaw/completions/openclaw.fish"
and source "$HOME/.openclaw/completions/openclaw.fish"
