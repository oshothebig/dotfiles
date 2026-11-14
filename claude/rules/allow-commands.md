---
paths:
  - "**/.claude/settings.json"
  - "**/.codex/rules/custom.rules"
---

# Codex `custom.rules` を Claude `settings.json` の allow list と一致させる

Claude Code の `~/.claude/settings.json` の `permissions.allow` と Codex CLI の `~/.codex/rules/custom.rules` は同じ「自動許可するコマンド集合」を表現する。両者は常に同じ集合を表すように保つ。

- `settings.json` を source of truth とし、`custom.rules` はその派生として更新する一方向同期
- `~/.codex/rules/default.rules` は Codex CLI 自身が管理するファイルなので触らない
