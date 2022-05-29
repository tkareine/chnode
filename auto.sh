# -*- sh-shell: bash; -*-

: "${CHNODE_AUTO_VERSION_FILENAME=.node-version}"

unset CHNODE_AUTO_VERSION

chnode_auto() {
    local dir="$PWD/" version_file version_found

    until [[ -z $dir ]]; do
        dir=${dir%/*}
        version_file="$dir/$CHNODE_AUTO_VERSION_FILENAME"

        if [[ -f "$version_file" && -r "$version_file" ]]; then
            read -r version_found <"$version_file" 2>/dev/null || true

            if [[ -n ${version_found:-} ]]; then
                version_found=${version_found%"${version_found##*[![:space:]]}"}

                if [[ ${version_found} == v[[:digit:]]* ]]; then
                    version_found=${version_found#v}
                fi

                if [[ $version_found == "${CHNODE_AUTO_VERSION:-}" ]]; then
                    return
                else
                    CHNODE_AUTO_VERSION=$version_found
                    chnode "$version_found"
                    return $?
                fi
            fi
        fi
    done

    if [[ -n ${CHNODE_AUTO_VERSION:-} ]]; then
        chnode_reset
        unset CHNODE_AUTO_VERSION
    fi
}
