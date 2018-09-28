# -*- sh-shell: bash; -*-

source support/fixture.sh

fixture_make_default_nodes

source chnode.sh

# shellcheck disable=SC2034
__ORG_CHNODE_NODES=("${CHNODE_NODES[@]}")

oneTimeTearDown() {
    fixture_delete_default_dir
}
