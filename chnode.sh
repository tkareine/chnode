# -*- sh-shell: bash; -*-

CHNODE_VERSION=0.0.1
CHNODE_NODES=()
: "${CHNODE_NODES_DIR=$HOME/.nodes}"

if [[ -d $CHNODE_NODES_DIR && \
          -z "$(\find "$CHNODE_NODES_DIR" -maxdepth 0 -type d -empty 2>/dev/null)" ]]; then
    CHNODE_NODES+=("$CHNODE_NODES_DIR"/*)
fi

chnode_reset() {
    [[ -z ${CHNODE_ROOT:-} ]] && return

    local path=:$PATH:
    path=${path//:$CHNODE_ROOT\/bin:/:}
    path=${path#:}
    path=${path%:}
    PATH=$path
    unset CHNODE_ROOT
    hash -r
}

chnode_use() {
    local root=$1

    if [[ ! -x "$root/bin/node" ]]; then
        echo "chnode: $root/bin/node not executable" >&2
        return 1
    fi

    [[ -n ${CHNODE_ROOT:-} ]] && chnode_reset

    export CHNODE_ROOT=$root
    export PATH=$CHNODE_ROOT/bin${PATH:+:$PATH}

    hash -r
}

chnode() {
    case "${1:-}" in
        -h|--help)
            echo "Usage: chnode [NODE_VERSION|reset]"
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
                case "$node" in
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
