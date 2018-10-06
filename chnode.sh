# -*- sh-shell: bash; -*-

CHNODE_VERSION=0.1.0
: "${CHNODE_NODES_DIR=$HOME/.nodes}"

chnode_reload() {
    local last_root=${CHNODE_ROOT:-}

    [[ -n $last_root ]] && chnode_reset

    CHNODE_NODES=()

    [[ ! (-d $CHNODE_NODES_DIR && -n "$(\ls -A "$CHNODE_NODES_DIR")") ]] && return

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

    local new_path=:$PATH:
    new_path=${new_path//:$last_root\/bin:/:}
    new_path=${new_path#:}
    new_path=${new_path%:}
    PATH=$new_path

    hash -r
}

chnode_use() {
    local new_root=$1

    if [[ ! -x "$new_root/bin/node" ]]; then
        echo "chnode: $new_root/bin/node not executable" >&2
        return 1
    fi

    [[ -n ${CHNODE_ROOT:-} ]] && chnode_reset

    export CHNODE_ROOT=$new_root
    export PATH=$CHNODE_ROOT/bin${PATH:+:$PATH}

    hash -r
}

chnode() {
    case ${1:-} in
        -h|--help)
            echo "Usage: chnode [-h|-V|-R|NODE_VERSION|reset]"
            ;;
        -R|--reload)
            chnode_reload
            ;;
        -V|--version)
            echo "chnode: $CHNODE_VERSION"
            ;;
        reset)
            chnode_reset
            ;;
        "")
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
            ;;
        *)
            local dir node given=$1 match
            shift
            for dir in "${CHNODE_NODES[@]}"; do
                dir="${dir%%/}"
                node="${dir##*/}"
                case $node in
                    "$given")
                        match=$dir
                        break
                        ;;
                    *"$given"*)
                        match=$dir
                        ;;
                esac
            done

            if [[ -z $match ]]; then
                echo "chnode: unknown Node.js: $given" >&2
                return 1
            fi

            chnode_use "$match"
            ;;
    esac
}

chnode_reload
