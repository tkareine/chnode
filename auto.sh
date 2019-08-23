# -*- sh-shell: bash; -*-

unset CHNODE_AUTO_VERSION

chnode_auto() {
    local dir="$PWD/" version

    until [[ -z $dir ]]; do
        dir=${dir%/*}

        if { read -r version <"$dir"/.node-version; } 2>/dev/null || [[ -n ${version:-} ]]; then
            if [[ $version == "${CHNODE_AUTO_VERSION:-}" ]]; then
                return
            else
                CHNODE_AUTO_VERSION=$version
                chnode "$version"
                return $?
            fi
        fi
    done

    if [[ -n ${CHNODE_AUTO_VERSION:-} ]]; then
        chnode_reset
        unset CHNODE_AUTO_VERSION
    fi
}
