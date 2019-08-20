# -*- sh-shell: bash; -*-

fixture_make_default_dir() {
    __FIXTURE_DEFAULT_DIR=$(mktemp -d /tmp/chnode-fixture.XXXXXX)
    __FIXTURE_DEFAULT_AUTO_DIR=$(mktemp -d /tmp/chnode-auto-fixture.XXXXXX)
}

fixture_delete_default_dir() {
    [[ -n ${__FIXTURE_DEFAULT_DIR:-} ]] && rm -rf "$__FIXTURE_DEFAULT_DIR"
    [[ -n ${__FIXTURE_DEFAULT_AUTO_DIR:-} ]] && rm -rf "$__FIXTURE_DEFAULT_AUTO_DIR"
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

fixture_make_default_auto_test_dirs() {
    [[ -z $1 ]] && echo "fixture_make_default_auto_test_dirs(): expects dir as first parameter" && return 1
    fixture_make_auto_test_dirs "$1" \
                           sub_dir\
                           modified_version\
                           bad\
                           sub_versioned
}

fixture_make_auto_test_dirs() {
  [[ -z $1 ]] && echo "fixture_make_auto_test_dir(): expects dir as first parameter" && return 1

    local dir=$1
    shift

    local name
    for name in "$@"; do
        mkdir -p "$dir/$name"
        chmod 755 "$dir/$name"
    done
}
