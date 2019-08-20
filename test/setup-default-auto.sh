# -*- sh-shell: bash; -*-

source support/fixture.sh

fixture_make_default_auto_dir
CHNODE_NODES_AUTO_DIR=$__FIXTURE_DEFAULT_AUTO_DIR
fixture_make_default_auto_test_dirs "$CHNODE_NODES_AUTO_DIR"

source auto.sh

# shellcheck disable=SC2034
__ORG_CHNODE_NODES=("${CHNODE_NODES[@]}")

export test_node_root="$CHNODE_NODES_DIR/node-8.1.0"

oneTimeTearDown() {
    fixture_delete_default_auto_dir
}
