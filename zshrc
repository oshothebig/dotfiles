# Temoporary solution avoiding Homebrew's path is placed
# at the end of PATH env var when running tmux.
export HOMEBREW_SHELLENV_PREFIX=""

# Homebrew
# Apple Silicon Mac
test -f /opt/homebrew/bin/brew && eval $(/opt/homebrew/bin/brew shellenv)
# Intel Mac
test -f /usr/local/bin/brew && eval $(/usr/local/bin/brew shellenv)

# PATH to user installed pip package executables
export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"

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
    # asdf-vm
    source ${HOMEBREW_PREFIX}/opt/asdf/asdf.sh
fi

# Alias
alias ls='ls --color'
alias repo='cd $(ghq list -p | peco)'

# pyenv
if type pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Go
if type go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
fi

# Starship
eval "$(starship init zsh)"

# Completion
autoload -Uz compinit && compinit

# Load local only settings if available
test -f ~/.zshrc.local && source ~/.zshrc.local

# Remove duplicated PATH entries
typeset -U path PATH
