# -*- sh-shell: bash; -*-

fixture_make_nodes_dir() {
    __FIXTURE_NODES_DIR=$(mktemp -d /tmp/chnode-nodes-fixture.XXXXXX)
}

fixture_make_auto_dir() {
    __FIXTURE_AUTO_DIR=$(mktemp -d /tmp/chnode-auto-fixture.XXXXXX)
}

fixture_delete_nodes_dir() {
    [[ -n ${__FIXTURE_NODES_DIR:-} ]] && rm -rf "$__FIXTURE_NODES_DIR"
}

fixture_delete_auto_dir() {
    [[ -n ${__FIXTURE_AUTO_DIR:-} ]] && rm -rf "$__FIXTURE_AUTO_DIR"
}

fixture_make_nodes() {
    [[ -z ${1:-} ]] && echo "fixture_make_nodes(): expects dir as first parameter" && return 1

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
    [[ -z ${1:-} ]] && echo "fixture_make_default_nodes(): expects dir as first parameter" && return 1

    fixture_make_nodes "$1" \
                       node-10.11.0 \
                       node-9.11.2 \
                       node-9.11.2-rc1 \
                       node-8.1.0 \
                       iojs-3.3.1
}
