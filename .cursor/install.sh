#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the dotfiles repository.
#
# The repository is normally installed on macOS via Homebrew, but the tools the
# repo's own tasks depend on (`just install`, `just format`) are just a handful
# of portable binaries. This script installs the Linux equivalents so a Cloud
# Agent can run and verify those tasks end to end.
set -euo pipefail

# Pinned to the versions used by the Format check GitHub workflow so local runs
# match CI (.github/workflows/format.yaml).
JUST_VERSION="1.50.0"
YAMLFMT_VERSION="0.21.0"

BIN_DIR="/usr/local/bin"

install_stow() {
    if command -v stow >/dev/null 2>&1; then
        return
    fi
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends stow
}

install_just() {
    if command -v just >/dev/null 2>&1 &&
        [ "$(just --version | awk '{print $2}')" = "$JUST_VERSION" ]; then
        return
    fi
    curl -fsSL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" |
        sudo tar -xz -C "$BIN_DIR" just
}

install_yamlfmt() {
    if command -v yamlfmt >/dev/null 2>&1 &&
        [ "$(yamlfmt -version 2>/dev/null)" = "$YAMLFMT_VERSION" ]; then
        return
    fi
    curl -fsSL "https://github.com/google/yamlfmt/releases/download/v${YAMLFMT_VERSION}/yamlfmt_${YAMLFMT_VERSION}_Linux_x86_64.tar.gz" |
        sudo tar -xz -C "$BIN_DIR" yamlfmt
}

install_stow
install_just
install_yamlfmt

echo "Installed tooling:"
printf '  stow    %s\n' "$(stow --version | head -1)"
printf '  just    %s\n' "$(just --version)"
printf '  yamlfmt %s\n' "$(yamlfmt -version)"
