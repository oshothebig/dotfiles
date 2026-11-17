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
