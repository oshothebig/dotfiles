# Pre-generated zsh completions for mise-managed tools.
#
# Instead of running `source <(<cmd> completion zsh)` in every new shell, the
# completion script of each tool version is generated once and cached:
#
#   $_MC_ROOT/versions/<mise-tool>/<mise-version>.zsh  generated scripts
#   $_MC_ROOT/active/<bin>.zsh                        symlinks to the active versions
#   $_MC_ROOT/map.zsh                                 bin -> mise tool names, built from `mise registry`
#
# Usage:
#   source mise-completions.zsh && _mc_sync --source-all  # ~/.zshrc, after compinit
#   _mc_sync                                              # mise cd hook (re-sources changed links)
#   zsh mise-completions.zsh postinstall                  # mise postinstall hook
#   zsh mise-completions.zsh prune                        # just prune-completions

# Commands that print a zsh completion script. The first word is the bin name;
# the mise tool providing it is looked up in the mise registry.
typeset -ga MISE_COMPLETION_COMMANDS=(
    'kind completion zsh'
    'kubectl completion zsh'
    'gh completion -s zsh'
    'just --completions zsh'
    'helm completion zsh'
    'flux completion zsh'
    'kustomize completion zsh'
    'stern --completion zsh'
    'hubble completion zsh'
    'cilium completion zsh'
    'cue completion zsh'
)

typeset -g _MC_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
typeset -g _MC_SELF="${${(%):-%x}:A}"
# _MC_BIN_TOOLS: bin -> space-separated tool names that may provide it (registry short
# names and their aliases, e.g. gh -> "github-cli gh"). The one in `mise current` wins.
typeset -gA _MC_BIN_TOOLS _MC_CURRENT

_mc_warn() {
    print -ru2 -- "mise-completions: $*"
}

# Prints "<bin> <tool names...>" for every bin in MISE_COMPLETION_COMMANDS found in the registry.
_mc_registry_lookup() {
    local -a bins=(${MISE_COMPLETION_COMMANDS%% *})
    mise registry --json --hide-aliased 2>/dev/null |
        jq -r '.[] | ([.short] + (.aliases // []) | join(" ")) as $tools
            | (.bins // [])[] | select(IN($ARGS.positional[])) | "\(.) \($tools)"' \
            --args -- $bins
}

# Rebuilds map.zsh from the mise registry. Requires jq.
_mc_build_map() {
    local map=$_MC_ROOT/map.zsh
    if (( ! $+commands[jq] )); then
        _mc_warn "jq not found; cannot build $map"
        return 1
    fi

    local -a lines
    lines=(${(f)"$(_mc_registry_lookup)"})
    if (( ! $#lines )); then
        _mc_warn "no tools found in the mise registry"
        return 1
    fi

    # Several registry tools may provide the same bin; keep them all.
    local -A found
    local line bin
    for line in $lines; do
        bin=${line%% *}
        found[$bin]="${found[$bin]:+${found[$bin]} }${line#* }"
    done

    for bin in ${MISE_COMPLETION_COMMANDS%% *}; do
        [[ -n ${found[$bin]} ]] || _mc_warn "$bin not found in the mise registry; skipped"
    done

    mkdir -p $_MC_ROOT || return 1
    print -r -- "typeset -gA _MC_BIN_TOOLS=(${(@kvq)found})" >| $map.tmp.$$ &&
        mv -f $map.tmp.$$ $map || return 1

    # The command list or the registry may have changed; retry failed generations.
    rm -f $_MC_ROOT/versions/*/*.failed(N)
}

_mc_load_map() {
    local map=$_MC_ROOT/map.zsh
    if [[ ! -r $map || $_MC_SELF -nt $map || ${commands[mise]:A} -nt $map ]]; then
        _mc_build_map || [[ -r $map ]] || return 1
    fi
    source $map
}

# Fills _MC_CURRENT (tool -> version) with the tool versions active in this shell.
#
# `mise activate` puts <data dir>/installs/<tool>/<version>[/bin] on PATH for every
# active tool, so the versions are read from $path without spawning a process
# (`mise current` alone costs as much as several completion generators). Falls back
# to `mise current` when mise is not activated (e.g. shims only).
_mc_read_current() {
    _MC_CURRENT=()
    local installs=${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/installs/
    local dir
    local -a parts
    for dir in $path; do
        [[ $dir == $installs* ]] || continue
        parts=(${(s:/:)dir#$installs})
        # The first entry wins, as it does for command lookup.
        (( $#parts >= 2 )) && [[ -z ${_MC_CURRENT[${parts[1]}]} ]] && _MC_CURRENT[${parts[1]}]=${parts[2]}
    done
    (( $#_MC_CURRENT )) && return 0

    local line
    local -a fields
    for line in ${(f)"$(mise current 2>/dev/null)"}; do
        fields=(${=line})
        (( $#fields >= 2 )) && _MC_CURRENT[${fields[1]}]=${fields[2]}
    done
}

# _mc_generate <tool> <version> <command...>
# Writes versions/<tool>/<version>.zsh. On failure, leaves a .failed marker so that
# startup and cd do not retry it every time.
_mc_generate() {
    local tool=$1 version=$2
    shift 2
    local out=$_MC_ROOT/versions/$tool/${version//\//_}.zsh
    local tmp=$out.tmp.$$
    mkdir -p ${out:h} || return 1

    print -ru2 -- "mise-completions: generating ${out/#$HOME/~}"
    if MISE_EXEC_AUTO_INSTALL=false mise exec "$tool@$version" -- "$@" >| $tmp 2>/dev/null && [[ -s $tmp ]]; then
        mv -f $tmp $out && rm -f ${out:r}.failed
    else
        rm -f $tmp
        : >| ${out:r}.failed
        _mc_warn "failed to generate the completion of $tool@$version ($*)"
        return 1
    fi
}

# _mc_sync [--source-all]
# Points active/<bin>.zsh at the version active in the current directory, generating
# missing scripts. Sources every active script with --source-all (shell startup),
# otherwise only the ones whose link changed (cd hook).
_mc_sync() {
    local source_all=0
    [[ $1 == --source-all ]] && source_all=1

    _mc_load_map || return 0
    _mc_read_current
    mkdir -p $_MC_ROOT/active || return 0

    local cmd bin tool candidate version target link
    local -a to_source
    for cmd in $MISE_COMPLETION_COMMANDS; do
        bin=${cmd%% *}
        link=$_MC_ROOT/active/$bin.zsh
        tool= version=
        for candidate in ${=_MC_BIN_TOOLS[$bin]}; do
            if [[ -n ${_MC_CURRENT[$candidate]} ]]; then
                tool=$candidate version=${_MC_CURRENT[$candidate]}
                break
            fi
        done

        if [[ -z $version ]]; then
            # Not active here. Keep the completion already loaded in this shell.
            [[ -L $link ]] && rm -f $link
            continue
        fi

        target=$_MC_ROOT/versions/$tool/${version//\//_}.zsh
        if [[ ! -s $target ]]; then
            if [[ -e ${target:r}.failed ]] || ! _mc_generate $tool $version ${(z)cmd}; then
                [[ -L $link ]] && rm -f $link
                continue
            fi
        fi

        if [[ ! -L $link || ${link:P} != ${target:P} ]]; then
            ln -s $target $link.tmp.$$ && mv -f $link.tmp.$$ $link || continue
            to_source+=($link)
        elif (( source_all )); then
            to_source+=($link)
        fi
    done

    local f
    for f in $to_source; do
        source $f
    done
}

_mc_postinstall() {
    if (( ! $+commands[jq] )); then
        _mc_warn "jq not found; completions will be generated on the next shell startup"
        return 0
    fi
    _mc_build_map || return 0
    source $_MC_ROOT/map.zsh

    local -A bin_to_cmd
    local cmd
    for cmd in $MISE_COMPLETION_COMMANDS; do
        bin_to_cmd[${cmd%% *}]=$cmd
    done

    local line tool version bin
    for line in ${(f)"$(jq -r '.[] | "\(.name) \(.version)"' <<<${MISE_INSTALLED_TOOLS:-[]} 2>/dev/null)"}; do
        tool=${line%% *} version=${line#* }
        for bin in ${(k)bin_to_cmd}; do
            (( ${${=_MC_BIN_TOOLS[$bin]}[(Ie)$tool]} )) && _mc_generate $tool $version ${(z)bin_to_cmd[$bin]}
        done
    done
    return 0
}

# Removes scripts of versions that are no longer installed, and dangling links.
_mc_prune() {
    if (( ! $+commands[jq] )); then
        _mc_warn "jq not found"
        return 1
    fi
    local -A installed
    local entry
    for entry in ${(f)"$(mise ls --installed --json | jq -r 'to_entries[] | .key as $tool | .value[] | "\($tool)/\(.version)"')"}; do
        installed[${entry//\//_}]=1
        installed[$entry]=1
    done
    (( $#installed )) || { _mc_warn "no installed tools reported by mise; nothing pruned"; return 1 }

    local f key
    for f in $_MC_ROOT/versions/*/*.(zsh|failed)(N); do
        key=${${f:h}:t}/${f:t:r}
        [[ -n ${installed[$key]} ]] || { print -r -- "removing ${f/#$HOME/~}"; rm -f $f }
    done
    rmdir $_MC_ROOT/versions/*(N/^F) 2>/dev/null
    for f in $_MC_ROOT/active/*(N@-@); do
        print -r -- "removing ${f/#$HOME/~}"
        rm -f $f
    done
    return 0
}

if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
    case $1 in
    postinstall) _mc_postinstall ;;
    prune) _mc_prune ;;
    *)
        print -ru2 -- "usage: zsh ${0:t} {postinstall|prune}"
        exit 2
        ;;
    esac
fi
