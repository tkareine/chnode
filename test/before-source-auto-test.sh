# -*- sh-shell: bash; -*-

source test/support/setup-shunit2.sh
source support/fixture.sh

setUp() {
    fixture_make_nodes_dir
    CHNODE_NODES_DIR=$__FIXTURE_NODES_DIR
    fixture_make_default_nodes "$CHNODE_NODES_DIR"
    fixture_make_auto_dir
}

tearDown() {
    fixture_delete_auto_dir
    fixture_delete_nodes_dir
}

test_preserve_custom_node_version_filename_when_source_auto() {
    local actual
    actual=$(
        # shellcheck disable=SC2034
        CHNODE_AUTO_VERSION_FILENAME=.nvmrc
        source chnode.sh
        source auto.sh

        cd "$__FIXTURE_AUTO_DIR" || exit

        echo "node-8.1.0" >.nvmrc
        chnode_auto
        echo "$?,$CHNODE_ROOT"
    )

    local expected
    # shellcheck disable=SC2031
    expected=$(cat <<END
0,$CHNODE_NODES_DIR/node-8.1.0
END
)

    assertEquals "$expected" "$actual"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
