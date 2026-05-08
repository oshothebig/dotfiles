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

zsh:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} zsh

ssh:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} ssh

git:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} git

bat:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} bat

helix:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} helix

ghostty:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} ghostty

sheldon:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} sheldon

claude:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} claude

mise:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} mise

migrate PACKAGE:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGE }}
    git diff
