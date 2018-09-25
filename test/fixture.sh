# -*- sh-shell: bash; -*-

__FIXTURE_DEFAULT_DIR=$(mktemp -d /tmp/chnode_benchmark.XXXXXX)
export CHNODE_NODES_DIR=$__FIXTURE_DEFAULT_DIR

fixture_delete_default_dir() {
    rm -fr "$__FIXTURE_DEFAULT_DIR"
}

trap fixture_delete_default_dir EXIT

fixture_make_nodes_dir() {
    local name
    for name in "$@"; do
        mkdir -p "$CHNODE_NODES_DIR/$name/bin"
        cat > "$CHNODE_NODES_DIR/$name/bin/node" <<END
#!/usr/bin/env bash

echo "I'm $name"
END
        chmod 755 "$CHNODE_NODES_DIR/$name/bin/node"
    done
}

fixture_make_nodes_dir \
    node-10.11.0 \
    node-9.11.2 \
    node-8.1.0 \
    node-6.0.0 \
    iojs-3.3.1
