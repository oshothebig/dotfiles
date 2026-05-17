set shell := ["bash", "-uc"]

packages := "zsh ssh git bat helix ghostty sheldon claude mise jj"

default:
    just --list

format:
    just --fmt

install *PACKAGES:
    stow -v --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ if PACKAGES == "" { packages } else { PACKAGES } }}

uninstall *PACKAGES:
    stow -v --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ if PACKAGES == "" { packages } else { PACKAGES } }}

migrate +PACKAGES:
    stow -v --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGES }}
    git diff
