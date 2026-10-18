# ==============================================================
# fish ships autosuggestions, syntax highlighting, and a native
# completion pager out of the box - no zinit/fisher/plugin
# manager needed. Each CLI below ships or generates its own
# fish integration; anything without one falls back to carapace.
# ==============================================================

# Homebrew first: GUI-launched terminals (Ghostty -> Zellij) don't
# inherit a login PATH, and everything below uses `type -q` checks.
test -x /opt/homebrew/bin/brew
and /opt/homebrew/bin/brew shellenv fish | source

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
# Syntax highlighting colors (Catppuccin Mocha, matches Ghostty,
# Zellij, and oh-my-posh). Known commands/builtins/functions stand
# out in bold green; anything fish can't resolve is bold red, so a
# typo is obvious before you hit enter.
# --------------------------------------------------------------
set -g fish_color_normal cdd6f4
set -g fish_color_command a6e3a1 --bold
set -g fish_color_keyword cba6f7 --bold
set -g fish_color_param f2cdcd
set -g fish_color_option f2cdcd
set -g fish_color_quote f9e2af
set -g fish_color_redirection f5c2e7
set -g fish_color_end fab387
set -g fish_color_error f38ba8 --bold
set -g fish_color_comment 7f849c --italics
set -g fish_color_operator f5c2e7
set -g fish_color_escape eba0ac
set -g fish_color_autosuggestion 6c7086
set -g fish_color_valid_path --underline
set -g fish_color_cwd f9e2af
set -g fish_color_cwd_root f38ba8
set -g fish_color_selection cdd6f4 --bold --background=313244
set -g fish_color_search_match --background=313244
set -g fish_pager_color_prefix cba6f7 --bold
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description 6c7086
set -g fish_pager_color_selected_background --background=313244

# --------------------------------------------------------------
# Greeting: swap the stock "Welcome to fish ... Type help ..."
# for macfetch's system summary (see config-src/cli/macfetch for
# the curated segment list) plus a rotating tip pulled from the
# tools this config already wires up. Falls back to a compact
# status line if macfetch isn't installed yet.
#
# No fish_greeting function - config.fish already only runs once
# per shell start, same as fish_greeting would, so a function here
# is pure indirection. `fish_greeting ''` suppresses the stock
# text (fish's own fish_greeting checks it's non-empty before
# printing); `status is-interactive` keeps this block from running
# for scripts and other non-interactive `fish -c ...` invocations.
# --------------------------------------------------------------
set -g fish_greeting ''

if status is-interactive
    if type -q macfetch
        macfetch
    else
        set -l uptime_str (uptime | string replace -r '.*up ' '' \
            | string replace -r ',?\s*\d+ users?.*' '' \
            | string replace -ra '\s+' ' ' | string trim)
        set -l os_version (sw_vers -productVersion 2>/dev/null)

        set_color --bold cba6f7
        echo -n (whoami)@(hostname -s)
        set_color 6c7086
        echo -n '  ·  '(date '+%a %d %b, %H:%M')
        set_color normal
        echo

        set_color a6e3a1
        echo -n "macOS $os_version"
        set_color 6c7086
        echo -n "  ·  fish $version  ·  up $uptime_str"
        set_color normal
        echo
    end

    set_color cba6f7
    echo -n '› '
    set_color cdd6f4
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
    # Pin the database location so zsm (Zellij) and the shell agree.
    set -gx _ZO_DATA_DIR "$HOME/Library/Application Support/zoxide"
    # Don't rank $HOME, secrets, temp dirs, or dependency/VCS internals.
    set -gx _ZO_EXCLUDE_DIRS "$HOME:$HOME/.ssh:$HOME/.ssh/*:/tmp/*:/private/*:*/node_modules/*:*/.git/*"
    # Store /tmp-style symlinks by their real path to avoid duplicates.
    set -gx _ZO_RESOLVE_SYMLINKS 1
    set -gx _ZO_FZF_OPTS "--height=40% --layout=reverse --border --preview='eza -1 --icons --color=always {2..}'"
    zoxide init --cmd cd fish | source
end

# --------------------------------------------------------------
# fzf: Ctrl+T paste path, Alt+C cd, ** completion, and Tab itself
# rebound to fzf's own fzf_complete widget (normally shift-tab-only)
# so any command's completion - `ls <Tab>`, `git checkout <Tab>`,
# `brew install <Tab>`, ... - opens the fuzzy picker instead of
# fish's plain completion pager. Ctrl+R is left to atuin, sourced
# after so its binding wins.
# --------------------------------------------------------------
if type -q fzf
    # fzf_complete runs fzf with --multi, where Tab means toggle-select
    # +down - so tabbing through the list marks every row it passes and
    # Enter inserts all of them. Rebind Tab/Shift+Tab inside the picker
    # to plain navigation and move multi-select to Ctrl+S.
    # Catppuccin Mocha, rounded border, vim-ish ctrl-j/k (fzf's default)
    # plus ctrl-d/u half-page scrolling of the preview.
    set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a,border:#6c7086,label:#cdd6f4 \
--border=rounded --layout=reverse --height=50% \
--bind=ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"
    set -gx FZF_COMPLETION_OPTS '--bind=tab:down,shift-tab:up,ctrl-s:toggle'
    set -gx FZF_EXPANSION_OPTS '--bind=tab:down,shift-tab:up,ctrl-s:toggle'
    fzf --fish | source
    bind \t fzf_complete
    bind -M insert \t fzf_complete
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
# Abbreviations
#   `abbr` (not `alias`) is the fish-recommended way to do this:
#   the full command is expanded into the commandline on space/
#   enter, so history and `type` show real commands, not an
#   opaque wrapper function. Trade-off: unlike alias, abbreviations
#   only expand for text typed at the prompt, never inside scripts
#   or other functions.
#   git aliases also live in ~/.gitconfig (co, br, ci, st, lg, ...);
#   the git/docker/kubectl snippets below are the shell-level layer
#   on top - skip typing the command name entirely. carapace (above)
#   still drives their TAB completion.
#
#   `ls` is the deliberate exception: as an abbreviation it expanded
#   into a wall of eza flags on every prompt line, and it only fired
#   for text typed interactively. A function (which is all fish's
#   `alias` builds anyway) keeps the prompt clean and applies inside
#   scripts and functions too. Guarded on eza so `ls` falls back to
#   the system binary on a machine where eza isn't installed yet.
#
#   The explicit `.` matters: given no path argument, eza prints
#   nothing at all when stdout isn't a tty, so `ls | wc -l` and
#   `set files (ls)` would silently come back empty. Harmless while
#   this was an abbr - those never expand outside the prompt - but a
#   real trap now that the name resolves everywhere. The test is for
#   a non-flag argument, not just any argument, so `ls -a | head`
#   gets the fallback too.
# --------------------------------------------------------------
if type -q eza
    function ls --description 'eza: long, grouped, icons, ISO timestamps'
        string match -qv -- '-*' $argv; or set -a argv .
        eza --long --group --group-directories-first --icons --header \
            --time-style long-iso $argv
    end
end
if type -q bat
    abbr -a cat bat
end
abbr -a vim nvim
abbr -a c clear
abbr -a bi 'brew install'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a l yazi
abbr -a k9 k9s
abbr -a zj 'zellij attach -c main'
test -f "$HOME/vnc.sh"
and abbr -a vnc "bash $HOME/vnc.sh"

# git
abbr -a gs 'git status -sb'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gc 'git commit'
abbr -a gcm 'git commit -m'
abbr -a gp 'git push'
abbr -a gpl 'git pull'
abbr -a gco 'git checkout'
abbr -a gb 'git branch'
abbr -a gd 'git diff'
abbr -a gl 'git lg'
abbr -a gst 'git stash'

# docker
if type -q docker
    abbr -a d docker
    abbr -a dc 'docker compose'
    abbr -a dps 'docker ps'
    abbr -a dex 'docker exec -it'
    abbr -a dlog 'docker logs -f'
end

# kubectl (k9s above got renamed to k9 so bare k is kubectl, the
# universal convention)
if type -q kubectl
    abbr -a k kubectl
    abbr -a kgp 'kubectl get pods'
    abbr -a kgs 'kubectl get svc'
    abbr -a kdp 'kubectl describe pod'
    abbr -a kaf 'kubectl apply -f'
    abbr -a kl 'kubectl logs -f'
    abbr -a kx 'kubectl exec -it'
end

# --------------------------------------------------------------
# wall - switch the desktop wallpaper (every display) to one of the
# Catppuccin set fetched by run_once_after_50-wallpapers.
#   wall            next image in the set
#   wall random     random image
#   wall forrest    first image whose name contains "forrest"
#   wall ls         list the set
# --------------------------------------------------------------
function wall --description 'Switch the macOS wallpaper within ~/Pictures/Wallpapers/catppuccin'
    set -l dir "$HOME/Pictures/Wallpapers/catppuccin"
    set -l imgs $dir/*.{jpg,png}
    if test (count $imgs) -eq 0
        echo "wall: no images in $dir (run chezmoi apply)" >&2
        return 1
    end
    set -l state "$dir/.current"
    set -l pick
    switch "$argv[1]"
        case ls
            for i in $imgs
                basename $i
            end
            return
        case random
            set pick $imgs[(random 1 (count $imgs))]
        case ''
            set -l cur (cat $state 2>/dev/null)
            set -l idx (contains -i -- "$cur" $imgs; or echo 0)
            set pick $imgs[(math "$idx % "(count $imgs)" + 1")]
        case '*'
            set pick (string match -e -- $argv[1] $imgs)[1]
            if test -z "$pick"
                echo "wall: no image matching '$argv[1]'" >&2
                return 1
            end
    end
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to POSIX file \"$pick\""
    and echo $pick >$state
    and echo (basename $pick)
end

# --------------------------------------------------------------
# Environment variables
# --------------------------------------------------------------
set -gx HOMEBREW_NO_AUTO_UPDATE 1
# nvim everywhere a tool asks for an editor: Claude Code / omp Ctrl+G
# (edit the prompt in $EDITOR), Zellij's Ctrl+a [ e (scrollback),
# git commit messages, `fish`'s Alt+e, gh, ... Zed stays one `zed .` away.
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx CHROME_EXECUTABLE "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# bat - colorized `cat` (abbreviated above) and manpager
if type -q bat
    set -gx BAT_THEME "Catppuccin Mocha"
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx MANROFFOPT -c
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

fish_add_path -P "$HOME/.local/bin"

# React Native / Android
set -gx JAVA_HOME (/usr/libexec/java_home 2>/dev/null)
set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
fish_add_path -P -a "$ANDROID_HOME/emulator" "$ANDROID_HOME/platform-tools"

# conda - CONDA_DISABLE_FISH_PROMPT skips conda.fish's fish_prompt/
# fish_right_prompt wrapping entirely. Without it, conda hijacks both
# prompt functions, and oh-my-posh's own env-var trick to suppress
# conda's *bash/zsh* prompt decoration (it sets CONDA_PROMPT_MODIFIER
# to the literal string "false" as a sentinel those shells check for)
# gets misread by fish's conda hook, which just echoes the value -
# hence a literal "false" appearing as the right prompt. oh-my-posh
# owns the prompt; `conda activate`/`deactivate` env management is
# unaffected by this flag.
set -gx CONDA_DISABLE_FISH_PROMPT 1
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

# worktrunk - `wt` git worktree manager; the shell function lets
# `wt switch` / `wt new` cd the current shell into the worktree.
if type -q wt
    wt config shell init fish | source
end

# ngrok
if type -q ngrok
    ngrok completion fish | source
end

# OpenClaw
test -f "$HOME/.openclaw/completions/openclaw.fish"
and source "$HOME/.openclaw/completions/openclaw.fish"
