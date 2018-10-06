# -*- sh-shell: bash; -*-

fixture_make_default_dir() {
    __FIXTURE_DEFAULT_DIR=$(mktemp -d /tmp/chnode-fixture.XXXXXX)
    trap fixture_delete_default_dir EXIT
}

fixture_delete_default_dir() {
    [[ -n ${__FIXTURE_DEFAULT_DIR:-} ]] && rm -rf "$__FIXTURE_DEFAULT_DIR"
}

fixture_make_nodes_dir() {
    [[ -z $1 ]] && echo "fixture_make_nodes_dir(): expects dir as first parameter" && return 1

    local dir=$1
    shift

    local name
    for name in "$@"; do
        mkdir -p "$dir/$name/bin"
        cat > "$dir/$name/bin/node" <<END
#!/usr/bin/env sh

echo "use: $name"
END
        chmod 755 "$dir/$name/bin/node"
    done
}

fixture_make_default_nodes() {
    [[ -z $1 ]] && echo "fixture_make_default_nodes(): expects dir as first parameter" && return 1

    fixture_make_nodes_dir "$1" \
                           node-10.11.0 \
                           node-9.11.2 \
                           node-9.11.2-rc1 \
                           node-8.1.0 \
                           iojs-3.3.1
}
