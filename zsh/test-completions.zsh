#!/usr/bin/env zsh
set -eu

function fail() {
    print -u2 -- "$1"
    exit 1
}

local rc="${0:A:h}/zshrc"
local test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
export XDG_CACHE_HOME="$test_dir/cache"
export FAKE_LOG="$test_dir/invocations"
local bin_dir="$test_dir/bin"
mkdir -p "$bin_dir"

printf '%s\n' '#!/usr/bin/env zsh' \
    'print -r -- "${0:t}:$*" >> "$FAKE_LOG"' \
    '[[ "${FAKE_FAIL:-}" == "${0:t}" ]] && exit 1' \
    'print -r -- "typeset -g completion_loaded=\"${0:t}:${FAKE_VERSION:-v1}\""' > "$test_dir/tool"
chmod +x "$test_dir/tool"

local -a names=(kind kubectl gh just helm flux kustomize stern hubble cilium cue)
local name
for name in $names; do
    ln -s "$test_dir/tool" "$bin_dir/$name"
done
export PATH="$bin_dir:$PATH"
rehash

source <(sed -n '/^function source_completion()/,/^}/p' "$rc")
function count_calls() {
    local count="$(wc -l < "$FAKE_LOG")"
    [[ "$count" -eq "$1" ]] || fail "Expected $1 generations, got $count"
}

source <(sed -n '/^source_completion kind /,/^source_completion cue /p' "$rc")
count_calls 11
local -a actual=("${(@f)$(< "$FAKE_LOG")}")
local -a expected=(
    'kind:completion zsh' 'kubectl:completion zsh' 'gh:completion -s zsh'
    'just:--completions zsh' 'helm:completion zsh' 'flux:completion zsh'
    'kustomize:completion zsh' 'stern:--completion zsh'
    'hubble:completion zsh' 'cilium:completion zsh' 'cue:completion zsh'
)
local i
for ((i = 1; i <= 11; i++)); do
    [[ "$actual[i]" == "$expected[i]" ]] || fail "Wrong arguments: $actual[i]"
done
source <(sed -n '/^source_completion kind /,/^source_completion cue /p' "$rc")
count_calls 11
print -- 'All 11 invocations and warm reuse: OK'

print -r -- '# changed' >> "$test_dir/tool"
source_completion kind completion zsh
count_calls 12
print -- 'Modified executable: OK'

mkdir -p "$test_dir/older" "$test_dir/oldest"
cp "$test_dir/tool" "$test_dir/older/kind"
cp "$test_dir/tool" "$test_dir/oldest/kind"
touch -t 202001010101 "$test_dir/older/kind"
touch -t 201901010101 "$test_dir/oldest/kind"
export PATH="$test_dir/older:$PATH"
rehash
export FAKE_VERSION=older
source_completion kind completion zsh
count_calls 13
[[ "$completion_loaded" == 'kind:older' ]] || fail 'PATH change not loaded'
export PATH="$test_dir/oldest:$PATH"
rehash
export FAKE_VERSION=oldest
source_completion kind completion zsh
count_calls 14
[[ "$completion_loaded" == 'kind:oldest' ]] || fail 'Older PATH binary not loaded'
print -- 'PATH switch to older executable: OK'

mkdir -p "$test_dir/links"
ln -s "$test_dir/older/kind" "$test_dir/links/kind"
export PATH="$test_dir/links:$PATH"
rehash
source_completion kind completion zsh
count_calls 15
ln -sfn "$test_dir/oldest/kind" "$test_dir/links/kind"
rehash
source_completion kind completion zsh
count_calls 16
print -- 'Symlink target switch: OK'

source_completion missing-command completion zsh
count_calls 16
[[ ! -e "$XDG_CACHE_HOME/zsh/completions/missing-command.zsh" ]] || fail 'Missing command cached'
print -- 'Missing tool: OK'

export FAKE_FAIL=gh
rm -f "$XDG_CACHE_HOME/zsh/completions/gh.zsh.stamp"
source_completion gh completion -s zsh
count_calls 17
[[ ! -e "$XDG_CACHE_HOME/zsh/completions/gh.zsh.stamp" ]] || fail 'Failed generation cached'
[[ ! -e "$XDG_CACHE_HOME/zsh/completions/gh.zsh.$$" ]] || fail 'Temporary file left behind'
unset FAKE_FAIL
source_completion gh completion -s zsh
count_calls 18
print -- 'Generation failure and retry: OK'

printf '%s\n' '#!/usr/bin/env zsh' \
    '[[ "$1" == which && -n "${MISE_TARGET:-}" ]] || exit 1' \
    'print -r -- "$MISE_TARGET"' > "$test_dir/links/mise"
chmod +x "$test_dir/links/mise"
ln -s mise "$test_dir/links/kind-shim"
export PATH="$test_dir/links:$PATH"
export MISE_TARGET="$test_dir/older/kind"
source_completion kind-shim completion zsh
count_calls 19
export MISE_TARGET="$test_dir/oldest/kind"
source_completion kind-shim completion zsh
count_calls 20
unset MISE_TARGET
source_completion kind-shim completion zsh
count_calls 20
print -- 'mise shim resolution and missing version: OK'
