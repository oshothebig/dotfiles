# Homebrew
eval $(/opt/homebrew/bin/brew shellenv)

# PATH to user installed pip package executables
export PATH="$HOME/.local/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

if [[ -n "${HOMEBREW_PREFIX}" ]]; then
    # coreutils
    export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
    # gnu-sed
    export PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
    # grep
    export PATH="${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin:$PATH"
    # gnu-tar
    export PATH="${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin:$PATH"
    # curl
    export PATH="${HOMEBREW_PREFIX}/opt/curl/bin:$PATH"
    # openssl
    export PATH="${HOMEBREW_PREFIX}/opt/openssl@1.1/bin:$PATH"
fi

# Use Helix for editor when available.
# Otherwise vim is used.
if type hx > /dev/null; then
    export EDITOR=hx
else
    export EDITOR=vim
fi

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Alias
alias ls='ls --color=auto'
alias ll='ls -lhF --color=auto'
alias la='ls -ahF --color=auto'
alias grep='grep --color=auto'
alias k='kubectl'
alias g='git'
alias ga='git add'
alias gs='git switch'

# mise
eval "$(mise activate zsh)"

# zoxide
eval "$(zoxide init zsh)"

export GHQ_ROOT=$HOME/src

function repo() {
    local selected="$(ghq list | fzf)"
    if [[ -z "$selected" ]]; then
        return 0
    fi
    z "$GHQ_ROOT/$selected"
}

# Go
if type go > /dev/null; then
    export GOPATH="$HOME/go"
    export PATH="${GOPATH}/bin:$PATH"
fi

# fzf
export FZF_DEFAULT_OPTS="--layout=reverse"

# Starship
if type starship > /dev/null; then
    eval "$(starship init zsh)"
fi

# zsh history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=100000
export SAVESIZE=100000
setopt extended_history
setopt append_history
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt hist_verify
setopt hist_no_store

function fzf-select-history() {
    local selected="$(history -n -r 1 | fzf --scheme=history --query "$LBUFFER")"
    if [[ -z "$selected" ]]; then
        return 0
    fi
    BUFFER="$selected"
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^R' fzf-select-history

# Delete a path segremnt when pressing Ctrl+w
export WORDCHARS="${WORDCHARS/\/}"

# Directory traversal
setopt auto_cd
setopt auto_pushd

# sheldon
eval "$(sheldon source)"

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*:default' menu select=2

function build_source_cache() {
    local cmd_name="$1"
    local cmd_bin_path="$(command -v $cmd_name)"

    if [[ -z "$cmd_bin_path" ]]; then
        return 0
    fi

    local cache_dir="$HOME/.cache/zsh"
    if [[ ! -d "$cache_dir" ]]; then
        mkdir -p "$cache_dir"
    fi

    local cache_path="$cache_dir/${cmd_name}.zsh"
    if [[ -r "$cache_path" && "$cache_path" -nt "$cmd_bin_path" ]]; then
        return 0
    fi

    print -P "%F{green}Generating cache: $cache_path"
    "$@" > "$cache_path"
}

build_source_cache kubectl completion zsh
zsh-defer source ~/.cache/zsh/kubectl.zsh

build_source_cache kind completion zsh
zsh-defer source ~/.cache/zsh/kind.zsh

# Load local only settings if available
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Remove duplicated PATH entries
typeset -U path PATH
