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
alias ls='ls --color'
alias k='kubectl'
alias repo='cd $(ghq list -p | fzf)'

export GHQ_ROOT=$HOME/src

# mise
eval "$(mise activate zsh)"

# Go
if type go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
    export PATH="${GOPATH}/bin:$PATH"
fi

# fzf
export FZF_DEFAULT_OPTS="--layout=reverse"

# Starship
if type starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# zsh history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=100000
export SAVESIZE=100000

# sheldon
eval "$(sheldon source)"

# Completion
autoload -Uz compinit && compinit
source <(kubectl completion zsh)

# Load local only settings if available
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Remove duplicated PATH entries
typeset -U path PATH
