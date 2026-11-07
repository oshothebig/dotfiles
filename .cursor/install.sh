#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the dotfiles repository.
#
# The repository is normally installed on macOS via Homebrew, but the tools the
# repo's own tasks depend on (`just install`, `just format`) are just a handful
# of portable binaries. This script installs the Linux equivalents so a Cloud
# Agent can run and verify those tasks end to end.
#
# just and yamlfmt are pinned in mise.toml at the repository root and installed
# with mise. stow is not available from mise, so it comes from apt.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="/usr/local/bin"
MISE="${HOME}/.local/bin/mise"

install_stow() {
    if command -v stow >/dev/null 2>&1; then
        return
    fi
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends stow
}

install_mise() {
    if command -v mise >/dev/null 2>&1; then
        MISE="$(command -v mise)"
        return
    fi
    if [ ! -x "$MISE" ]; then
        curl -fsSL https://mise.run | sh
    fi
}

install_mise_tools() {
    cd "$REPO_DIR"
    "$MISE" trust --yes mise.toml
    "$MISE" install --yes
    # Expose the pinned binaries on the default PATH so agent shells that do
    # not activate mise can still find them.
    for tool in just yamlfmt; do
        sudo ln -sf "$("$MISE" which "$tool")" "$BIN_DIR/$tool"
    done
}

install_stow
install_mise
install_mise_tools

echo "Installed tooling:"
printf '  stow    %s\n' "$(stow --version | head -1)"
printf '  mise    %s\n' "$("$MISE" --version)"
printf '  just    %s\n' "$(just --version)"
printf '  yamlfmt %s\n' "$(yamlfmt -version)"
