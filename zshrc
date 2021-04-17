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
fi

# Alias
alias ls='ls --color'

# Go
if type go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
fi

# Completion
autoload -Uz compinit && compinit

# Load local only settings if available
test -f ~/.zshrc.local && source ~/.zshrc.local
