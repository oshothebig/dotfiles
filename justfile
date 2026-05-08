set shell := ["bash", "-uc"]

default:
    just --list

format:
    just --fmt

install: zsh ssh git bat helix ghostty sheldon claude

uninstall:
    stow --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} zsh ssh git bat helix ghostty sheldon claude

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

migrate PACKAGE:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGE }}
    git diff
