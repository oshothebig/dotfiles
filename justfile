set shell := ["bash", "-uc"]

default:
    just --list

format:
    just --fmt
    yamlfmt .

install: install-dotfiles

# Deploy the [dotfiles] entries declared in mise.toml.
install-dotfiles:
    mise dotfiles apply --yes

uninstall: uninstall-dotfiles

# Remove the files deployed by install-dotfiles; sources and mise.toml entries are kept.
uninstall-dotfiles:
    mise dotfiles unapply --yes

# Remove pre-generated zsh completions of mise tool versions that are no longer installed.
prune-completions:
    zsh ~/.config/zsh/mise-completions.zsh prune
