# -*- sh-shell: bash; -*-

source test/setup-shunit2.sh
source test/setup-default-chnode.sh
source auto.sh

setUp() {
    chnode -r
    fixture_make_auto_dir
}

tearDown() {
    fixture_delete_auto_dir
}

test_chnode_auto_cd_dirs() {
    local actual_roots
    actual_roots=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        chnode_auto
        echo "0,$PWD,$?,$CHNODE_ROOT"

        mkdir sub1
        echo node-8.1.0 >sub1/.node-version
        cd sub1 || exit
        chnode_auto
        echo "1,$PWD,$?,$CHNODE_ROOT"

        mkdir sub2
        cd sub2 || exit
        chnode_auto
        echo "2,$PWD,$?,$CHNODE_ROOT"

        cd "$__FIXTURE_AUTO_DIR" || exit
        mkdir sub3
        echo node-10.11.0 >sub3/.node-version
        cd sub3 || exit
        chnode_auto
        echo "3,$PWD,$?,$CHNODE_ROOT"

        cd ..
        chnode_auto
        echo "4,$PWD,$?,$CHNODE_ROOT"
    )

    local expected_roots
    expected_roots=$(cat <<END
0,$__FIXTURE_AUTO_DIR,0,
1,$__FIXTURE_AUTO_DIR/sub1,0,$CHNODE_NODES_DIR/node-8.1.0
2,$__FIXTURE_AUTO_DIR/sub1/sub2,0,$CHNODE_NODES_DIR/node-8.1.0
3,$__FIXTURE_AUTO_DIR/sub3,0,$CHNODE_NODES_DIR/node-10.11.0
4,$__FIXTURE_AUTO_DIR,0,
END
)

    assertEquals "$expected_roots" "$actual_roots"
}

test_chnode_auto_modify_node_version_file() {
    local actual_roots
    actual_roots=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        chnode_auto
        echo "0,$?,$CHNODE_ROOT"

        echo node-8.1.0 >.node-version
        chnode_auto
        echo "1,$?,$CHNODE_ROOT"

        echo nosuch >.node-version
        chnode_auto 2>/dev/null
        echo "2,$?,$CHNODE_ROOT"

        rm .node-version
        chnode_auto
        echo "3,$?,$CHNODE_ROOT"
    )

    local expected_roots
    expected_roots=$(cat <<END
0,0,
1,0,$CHNODE_NODES_DIR/node-8.1.0
2,1,$CHNODE_NODES_DIR/node-8.1.0
3,0,
END
)

    assertEquals "$expected_roots" "$actual_roots"
}

test_chnode_auto_selects_by_first_line_in_node_version_file() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        echo -e "\t node-8.1.0\t \nnode-10.11.0" >.node-version
        chnode_auto
        echo "$?,$CHNODE_ROOT"
    )

    local expected
    expected=$(cat <<END
0,$CHNODE_NODES_DIR/node-8.1.0
END
)

    assertEquals "$expected" "$actual"
}

test_chnode_auto_supports_fuzzy_matching_in_node_version_file() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        echo -e "node-8" >.node-version
        chnode_auto
        echo "$?,$CHNODE_ROOT"
    )

    local expected
    expected=$(cat <<END
0,$CHNODE_NODES_DIR/node-8.1.0
END
)

    assertEquals "$expected" "$actual"
}

test_chnode_auto_resets_chnode() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        chnode node-10.11.0
        echo "0,$?,$CHNODE_ROOT"

        mkdir sub1
        echo node-8.1.0 >sub1/.node-version
        cd sub1 || exit
        chnode_auto
        echo "1,$?,$CHNODE_ROOT"

        cd ..
        chnode_auto
        echo "2,$?,$CHNODE_ROOT"
    )

    local expected
    expected=$(cat <<END
0,0,$CHNODE_NODES_DIR/node-10.11.0
1,0,$CHNODE_NODES_DIR/node-8.1.0
2,0,
END
)

    assertEquals "$expected" "$actual"
}

test_chnode_auto_errors_once_when_unknown_node_version() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        echo nosuch >.node-version

        chnode_auto 2>&1
        printf "0,%d,%s\n\n" $? "$CHNODE_ROOT"

        chnode_auto 2>&1
        printf "1,%d,%s\n\n" $? "$CHNODE_ROOT"
    )

    local expected
    expected=$(cat <<END
chnode: unknown Node.js: nosuch
0,1,

1,0,
END
)

    assertEquals "$expected" "$actual"
}

test_chnode_auto_use_custom_node_version_filename() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        echo "node-8.1.0" >.nvmrc
        # shellcheck disable=SC2034
        CHNODE_AUTO_VERSION_FILENAME=.nvmrc
        chnode_auto
        echo "$?,$CHNODE_ROOT"
    )

    local expected
    expected=$(cat <<END
0,$CHNODE_NODES_DIR/node-8.1.0
END
)

    assertEquals "$expected" "$actual"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
