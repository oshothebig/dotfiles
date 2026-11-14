set shell := ["bash", "-uc"]

packages_nofold := "zsh ssh git claude mise jj codex"
packages_fold := "helix sheldon"

default:
    just --list

format:
    just --fmt
    yamlfmt .

install: install-nofold install-fold install-copy-files install-dotfiles

create-config-dir:
    mkdir -p {{ home_directory() }}/.config

install-nofold: create-config-dir
    stow -v --no-folding --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_nofold }}

install-copy-files:
    # Codex doesn't read *.rules files when they are symlinks.
    mkdir -p {{ home_directory() }}/.codex/rules
    cp {{ justfile_directory() }}/codex/.codex/rules/*.rules {{ home_directory() }}/.codex/rules/

install-fold: create-config-dir
    stow -v --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_fold }}

# Deploy the [dotfiles] entries declared in mise.toml.
install-dotfiles:
    mise dotfiles apply --yes

uninstall: uninstall-nofold uninstall-fold uninstall-copy-files uninstall-dotfiles

uninstall-nofold:
    stow -v --no-folding --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_nofold }}

uninstall-fold:
    stow -v --delete --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ packages_fold }}

# Remove the files deployed by install-dotfiles; sources and mise.toml entries are kept.
uninstall-dotfiles:
    mise dotfiles unapply --yes

uninstall-copy-files:
    # Remove only the files installed by install-copy-files; keep other rules such as Codex-generated ones.
    for f in {{ justfile_directory() }}/codex/.codex/rules/*.rules; do rm -fv "{{ home_directory() }}/.codex/rules/$(basename "$f")"; done

migrate +PACKAGES:
    stow -v --adopt --dir={{ justfile_directory() }} --target={{ home_directory() }} {{ PACKAGES }}
    git diff
