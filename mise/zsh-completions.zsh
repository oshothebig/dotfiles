# Helpers for mise-managed tool completions (source, not fpath).
# Deployed to ~/.config/mise/zsh-completions.zsh

typeset -gA _MISE_ZSH_COMPLETION_ACTIVE

function _mise_zsh_completions_root() {
	print -r -- "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
}

function _mise_zsh_completions_sync() {
	local script="${HOME}/.config/mise/zsh-completions.py"
	if [[ ! -r "$script" ]]; then
		return 0
	fi
	# Prefer mise-managed python when available; fall back to system python3.
	if command -v python3 >/dev/null 2>&1; then
		python3 "$script" activate || true
	fi
}

function _mise_zsh_completions_source() {
	local root active_dir f cmd target
	root="$(_mise_zsh_completions_root)"
	active_dir="${root}/active"
	[[ -d "$active_dir" ]] || return 0

	for f in "$active_dir"/*.zsh(N); do
		cmd="${f:t:r}"
		target="$(readlink "$f" 2>/dev/null || print -r -- "$f")"
		if [[ "${_MISE_ZSH_COMPLETION_ACTIVE[$cmd]}" == "$target" ]]; then
			continue
		fi
		# shellcheck disable=SC1090
		source "$f"
		_MISE_ZSH_COMPLETION_ACTIVE[$cmd]="$target"
	done
}

function _mise_zsh_completions_refresh() {
	_mise_zsh_completions_sync
	_mise_zsh_completions_source
}
