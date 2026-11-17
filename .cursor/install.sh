#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap. Tools are pinned in mise.toml.
# Agent shells reset PATH and do not activate mise, so shims go in /usr/local/bin.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

export PATH="${HOME}/.local/bin:${PATH}"
command -v mise >/dev/null || curl -fsSL https://mise.run | sh

mise trust --yes
mise install --yes
sudo ln -sfn "${HOME}/.local/share/mise/shims/"* /usr/local/bin/
