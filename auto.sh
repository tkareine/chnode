# -*- sh-shell: bash; -*-

: "${CHNODE_AUTO_VERSION_FILENAME=.node-version}"

unset CHNODE_AUTO_VERSION

chnode_auto() {
    local dir="$PWD/" version

    until [[ -z $dir ]]; do
        dir=${dir%/*}

        if { read -r version <"$dir"/"$CHNODE_AUTO_VERSION_FILENAME"; } 2>/dev/null || [[ -n ${version:-} ]]; then
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
