set shell := ["bash", "-uc"]

config_dir := home_directory() / ".config"

default:
    just --list

format:
    just --fmt

install: zsh ssh git bat helix ghostty sheldon claude

uninstall:
    unlink {{ home_directory() }}/.zshrc
    unlink {{ home_directory() }}/.ssh/config
    unlink {{ config_dir }}/git/config
    unlink {{ config_dir }}/bat
    unlink {{ config_dir }}/helix
    unlink {{ config_dir }}/ghostty
    unlink {{ config_dir }}/sheldon
    unlink {{ home_directory() }}/.claude/settings.json
    unlink {{ home_directory() }}/.claude/CLAUDE.md

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

_dotfile TARGET:
    if [[ -e {{ home_directory() }}/.{{ TARGET }} ]]; then \
        echo "{{ home_directory() }}.{{ TARGET }} exists, do nothing"; \
    else \
        ln -s {{ justfile_directory() }}/{{ TARGET }} {{ home_directory() }}/.{{ TARGET }}; \
    fi

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

_config TARGET:
    # Create ~/.config directory if not exists
    if [[ ! -d {{ config_dir }} ]]; then \
        mkdir -p {{ config_dir }}; \
    fi

    # Create a symlink for the target config
    if [[ -d {{ config_dir }}/{{ TARGET }} ]]; then \
        echo "{{ config_dir }}/{{ TARGET }} exists, do nothing"; \
    else \
        ln -s {{ justfile_directory() }}/{{ TARGET }} {{ config_dir }}/{{ TARGET }}; \
    fi
