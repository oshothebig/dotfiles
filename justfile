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

zsh-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} zsh
    git diff -- zsh

ssh:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} ssh

ssh-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} ssh
    git diff -- ssh

git:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} git

git-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} git
    git diff -- git

bat:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} bat

bat-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} bat
    git diff -- bat

helix:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} helix

helix-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} helix
    git diff -- helix

ghostty:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} ghostty

ghostty-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} ghostty
    git diff -- ghostty

sheldon:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} sheldon

sheldon-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} sheldon
    git diff -- sheldon

claude:
    stow --dir={{ justfile_directory() }} --target={{ home_directory() }} claude

claude-migrate:
    stow --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} claude
    git diff -- claude
