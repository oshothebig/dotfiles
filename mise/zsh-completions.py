#!/usr/bin/env python3
"""Generate and retarget zsh completions for an allowlist of mise-managed tools.

Layout under ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions:
  versions/<mise-tool>/<mise-version>.zsh
  active/<command>.zsh -> ../versions/<mise-tool>/<mise-version>.zsh

Usage:
  zsh-completions.py postinstall  # mise [hooks].postinstall
  zsh-completions.py activate     # retarget actives; generate on miss
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from functools import lru_cache
from pathlib import Path

# Completion generator argv after the resolved bin name.
# Keys are mise tool names (not necessarily the bin name).
GENERATOR_ARGS: dict[str, list[str]] = {
    "kind": ["completion", "zsh"],
    "kubectl": ["completion", "zsh"],
    "gh": ["completion", "-s", "zsh"],
    "just": ["--completions", "zsh"],
    "helm": ["completion", "zsh"],
    "flux2": ["completion", "zsh"],
    "kustomize": ["completion", "zsh"],
    "stern": ["--completion", "zsh"],
    "cilium-hubble": ["completion", "zsh"],
    "cilium-cli": ["completion", "zsh"],
    "cue": ["completion", "zsh"],
}

BIN_FALLBACK: dict[str, str] = {
    "kind": "kind",
    "kubectl": "kubectl",
    "gh": "gh",
    "just": "just",
    "helm": "helm",
    "flux2": "flux",
    "kustomize": "kustomize",
    "stern": "stern",
    "cilium-hubble": "hubble",
    "cilium-cli": "cilium",
    "cue": "cue",
}


def cache_root() -> Path:
    xdg = os.environ.get("XDG_CACHE_HOME")
    base = Path(xdg) if xdg else Path.home() / ".cache"
    return base / "zsh" / "completions"


def log(msg: str) -> None:
    print(f"mise zsh-completions: {msg}", file=sys.stderr)


def safe_version(version: str) -> str:
    return version.replace("/", "_")


def run_json(args: list[str]) -> object | None:
    try:
        raw = subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL)
        return json.loads(raw)
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        return None


@lru_cache(maxsize=None)
def bin_for_tool(tool: str) -> str:
    data = run_json(["mise", "registry", "-J", tool])
    if isinstance(data, list):
        data = data[0] if data else {}
    if isinstance(data, dict):
        bins = data.get("bins") or []
        if bins:
            return str(bins[0])
    return BIN_FALLBACK.get(tool, tool)


def version_file(root: Path, tool: str, version: str) -> Path:
    return root / "versions" / tool / f"{safe_version(version)}.zsh"


def generate_version(root: Path, tool: str, version: str) -> Path | None:
    if tool not in GENERATOR_ARGS:
        return None

    path = version_file(root, tool, version)
    path.parent.mkdir(parents=True, exist_ok=True)
    bin_name = bin_for_tool(tool)
    cmd = ["mise", "exec", f"{tool}@{version}", "--", bin_name, *GENERATOR_ARGS[tool]]
    tmp = path.with_suffix(".zsh.tmp")
    try:
        with tmp.open("w", encoding="utf-8") as fh:
            subprocess.check_call(cmd, stdout=fh, stderr=subprocess.DEVNULL)
        tmp.replace(path)
    except (OSError, subprocess.CalledProcessError):
        if tmp.exists():
            tmp.unlink()
        log(f"failed to generate completion for {tool}@{version}")
        return None

    log(f"wrote {path}")
    return path


def link_active(root: Path, tool: str, version: str, bin_name: str) -> Path | None:
    version_path = version_file(root, tool, version)
    if not version_path.is_file():
        return None
    active_dir = root / "active"
    active_dir.mkdir(parents=True, exist_ok=True)
    active_path = active_dir / f"{bin_name}.zsh"
    rel = Path("..") / "versions" / tool / f"{safe_version(version)}.zsh"
    if active_path.is_symlink() or active_path.exists():
        active_path.unlink()
    active_path.symlink_to(rel)
    return active_path


def ensure_tool_version(root: Path, tool: str, version: str) -> str | None:
    """Ensure versions file + active symlink. Returns bin name on success."""
    path = version_file(root, tool, version)
    if not path.is_file():
        if generate_version(root, tool, version) is None:
            return None
    bin_name = bin_for_tool(tool)
    if link_active(root, tool, version, bin_name) is None:
        return None
    return bin_name


def current_allowlisted() -> list[tuple[str, str]]:
    data = run_json(["mise", "ls", "--current", "--json"])
    if not isinstance(data, dict):
        return []
    out: list[tuple[str, str]] = []
    for tool, entries in data.items():
        if tool not in GENERATOR_ARGS or not isinstance(entries, list):
            continue
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            if not entry.get("installed") or not entry.get("active"):
                continue
            version = entry.get("version")
            if version:
                out.append((tool, str(version)))
    return out


def retarget_actives(root: Path) -> None:
    (root / "versions").mkdir(parents=True, exist_ok=True)
    (root / "active").mkdir(parents=True, exist_ok=True)

    linked_bins: set[str] = set()
    for tool, version in current_allowlisted():
        bin_name = ensure_tool_version(root, tool, version)
        if bin_name:
            linked_bins.add(bin_name)

    active_dir = root / "active"
    for path in active_dir.glob("*.zsh"):
        bin_name = path.name[: -len(".zsh")]
        if bin_name not in linked_bins:
            path.unlink()


def postinstall(root: Path) -> None:
    raw = os.environ.get("MISE_INSTALLED_TOOLS", "[]")
    try:
        tools = json.loads(raw)
    except json.JSONDecodeError:
        tools = []

    if isinstance(tools, list):
        for entry in tools:
            if not isinstance(entry, dict):
                continue
            name = entry.get("name")
            version = entry.get("version")
            if name in GENERATOR_ARGS and version:
                generate_version(root, str(name), str(version))

    retarget_actives(root)


def activate(root: Path) -> None:
    retarget_actives(root)


def main(argv: list[str]) -> int:
    if len(argv) != 2 or argv[1] not in {"postinstall", "activate"}:
        print(f"usage: {argv[0]} {{postinstall|activate}}", file=sys.stderr)
        return 2

    root = cache_root()
    if argv[1] == "postinstall":
        postinstall(root)
    else:
        activate(root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
