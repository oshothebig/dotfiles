#!/usr/bin/env bash

set -euo pipefail

# Configure where ghq stores repositories during bootstrap.
export GHQ_ROOT="$HOME/src"

# Install Homebrew first because the rest of the bootstrap depends on it.
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make brew available for the following bootstrap steps.
# This assumes Apple Silicon Mac only.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install software declared in Brewfile of the dotfiles repository.
curl -fsSL "https://raw.githubusercontent.com/oshothebig/dotfiles/main/Brewfile" | brew bundle --file=-
