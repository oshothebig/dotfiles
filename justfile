set shell := ["bash", "-uc"]

packages_nofold := "zsh ssh git claude mise jj"
packages_fold := "bat helix ghostty sheldon"

default:
    just --list

format:
    just --fmt

install: create-config-dir install-nofold install-fold

create-config-dir:
    mkdir -p {{ home_directory() }}/.config

install-nofold:
    stow -v --no-folding --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_nofold }}

install-fold:
    stow -v --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_fold }}

uninstall: uninstall-nofold uninstall-fold

uninstall-nofold:
    stow -v --no-folding --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_nofold }}

uninstall-fold:
    stow -v --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_fold }}

migrate +PACKAGES:
    stow -v --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGES }}
    git diff
