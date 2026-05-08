set shell := ["bash", "-uc"]

packages := "zsh ssh git bat helix ghostty sheldon claude mise"

default:
    just --list

format:
    just --fmt

install *PACKAGES:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ if PACKAGES == "" { packages } else { PACKAGES } }}

uninstall *PACKAGES:
    stow --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ if PACKAGES == "" { packages } else { PACKAGES } }}

migrate PACKAGE:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGE }}
    git diff
