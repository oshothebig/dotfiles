# dotfiles
My dotfiles

## Bootstrap a new Mac

This bootstrap script assumes an Apple Silicon Mac.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/oshothebig/dotfiles/main/bootstrap.sh)"
```

## Setup

```sh
export GHQ_ROOT="$HOME/src"
ghq get https://github.com/oshothebig/dotfiles.git
cd "$GHQ_ROOT/github.com/oshothebig/dotfiles"
just install
```
