# -*- sh-shell: bash; -*-

source support/fixture.sh

fixture_make_nodes_dir
CHNODE_NODES_DIR=$__FIXTURE_NODES_DIR
fixture_make_default_nodes "$CHNODE_NODES_DIR"

source chnode.sh

# shellcheck disable=SC2034
__ORG_CHNODE_NODES=("${CHNODE_NODES[@]}")

oneTimeTearDown() {
    fixture_delete_nodes_dir
}
