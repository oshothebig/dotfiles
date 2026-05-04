#!/usr/bin/env bash

set -euo pipefail

export GHQ_ROOT="$HOME/src"

if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

brew install git ghq just
