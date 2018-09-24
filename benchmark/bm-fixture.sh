# -*- sh-shell: bash; -*-

CHNODE_NODES_DIR=$(mktemp -d /tmp/chnode_benchmark.XXXXXX)

delete_nodes_dir() {
    rm -fr "$CHNODE_NODES_DIR"
}

trap delete_nodes_dir EXIT

export CHNODE_NODES_DIR

make_nodes_dir() {
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

make_nodes_dir \
    node-10.11.0 \
    node-9.11.2 \
    node-8.1.0 \
    node-6.0.0 \
    iojs-3.3.1
