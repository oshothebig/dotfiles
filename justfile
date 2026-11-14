set shell := ["bash", "-uc"]

packages_nofold := "mise"

default:
    just --list

format:
    just --fmt
    yamlfmt .

install: install-nofold install-dotfiles

create-config-dir:
    mkdir -p {{ home_directory() }}/.config

install-nofold: create-config-dir
    stow -v --no-folding --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_nofold }}

# Deploy the [dotfiles] entries declared in mise.toml.
install-dotfiles:
    mise dotfiles apply --yes

uninstall: uninstall-nofold uninstall-dotfiles

uninstall-nofold:
    stow -v --no-folding --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_nofold }}

# Remove the files deployed by install-dotfiles; sources and mise.toml entries are kept.
uninstall-dotfiles:
    mise dotfiles unapply --yes

migrate +PACKAGES:
    stow -v --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGES }}
    git diff
