# -*- sh-shell: bash; -*-

__FIXTURE_DEFAULT_DIR=$(mktemp -d /tmp/chnode-fixture.XXXXXX)

fixture_delete_default_dir() {
    rm -fr "$__FIXTURE_DEFAULT_DIR"
}

trap fixture_delete_default_dir EXIT

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
  fixture_make_nodes_dir "$__FIXTURE_DEFAULT_DIR" \
      node-10.11.0 \
      node-9.11.2 \
      node-9.11.2-rc1 \
      node-8.1.0 \
      iojs-3.3.1

  export CHNODE_NODES_DIR=$__FIXTURE_DEFAULT_DIR
}
