# -*- sh-shell: bash; -*-

CHNODE_VERSION=0.4.3
: "${CHNODE_NODES_DIR=$HOME/.nodes}"

chnode_replace_path() {
    local last_root=$1 new_root=${2:-}

    local new_path=:$PATH:
    local replacement_new_root

    if [[ -n $new_root ]]; then
        replacement_new_root=:$new_root/bin:
    else
        replacement_new_root=:
    fi

    new_path=${new_path//:$last_root\/bin:/"$replacement_new_root"}
    new_path=${new_path#:}
    new_path=${new_path%:}

    PATH=$new_path
}

chnode_reload() {
    local last_root=${CHNODE_ROOT:-}

    [[ -n $last_root ]] && chnode_reset

    CHNODE_NODES=()

    [[ ! (-d $CHNODE_NODES_DIR && -n "$(command ls "$CHNODE_NODES_DIR")") ]] && return

    CHNODE_NODES+=("$CHNODE_NODES_DIR"/*)

    [[ -z $last_root ]] && return

    local dir
    for dir in "${CHNODE_NODES[@]}"; do
        if [[ $dir == "$last_root" ]]; then
            if chnode_use "$dir"; then
                return
            else
                return 1
            fi
        fi
    done
}

chnode_reset() {
    local last_root=${CHNODE_ROOT:-}

    unset CHNODE_ROOT

    [[ -z $last_root ]] && return

    chnode_replace_path "$last_root"

    hash -r
}

chnode_use() {
    local new_root=$1

    if [[ ! -x "$new_root/bin/node" ]]; then
        echo "chnode: $new_root/bin/node not executable" >&2
        return 1
    fi

    if [[ -n ${CHNODE_ROOT:-} ]]; then
        chnode_replace_path "$CHNODE_ROOT" "$new_root"
    else
        PATH=$new_root/bin:$PATH
    fi

    export CHNODE_ROOT=$new_root
    export PATH

    hash -r
}

chnode_match() {
    local dir node given=$1
    for dir in "${CHNODE_NODES[@]}"; do
        dir="${dir%%/}"
        node="${dir##*/}"
        case $node in
            "$given")
                match_output=$dir
                break
                ;;
            *"$given"*)
                match_output=$dir
                ;;
        esac
    done
}

chnode_list() {
    local dir node
    for dir in "${CHNODE_NODES[@]}"; do
        dir="${dir%/}"
        node="${dir##*/}"
        if [[ $dir == "${CHNODE_ROOT:-}" ]]; then
            echo " * ${node}"
        else
            echo "   ${node}"
        fi
    done
}

chnode() {
    case ${1:-} in
        -h | --help)
            echo "Usage: chnode [-h|-r|-R|-V|NODE_VERSION]"
            ;;
        -r | --reset)
            chnode_reset
            ;;
        -R | --reload)
            chnode_reload
            ;;
        -V | --version)
            echo "chnode: $CHNODE_VERSION"
            ;;
        "")
            chnode_list
            ;;
        *)
            local match_output
            chnode_match "$1"

            if [[ -z $match_output ]]; then
                echo "chnode: unknown Node.js: $1" >&2
                return 1
            fi

            chnode_use "$match_output"
            ;;
    esac
}

chnode_reload
