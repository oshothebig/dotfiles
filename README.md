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
git remote set-url origin git@github.com:oshothebig/dotfiles.git
just install
```

## Software installed manually

### Claude Code

Anthropic recommends native installation over Homebrew. In addition, I want to use the auto-update feature, which is not available when installing via Homebrew.

```sh
curl -fsSL https://claude.ai/install.sh | bash
```

as described in https://code.claude.com/docs/ja/quickstart#native-install-recommended.

### Amp

Amp doesn't provide installation via Homebrew. The following installation method is recommended.

```sh
curl -fsSL https://ampcode.com/install.sh | bash
```

as described in https://ampcode.com/manual#getting-started-command-line-interface.
