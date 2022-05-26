# -*- sh-shell: bash; -*-

source test/support/setup-shunit2.sh
source test/support/setup-default-chnode.sh
source auto.sh

setUp() {
    chnode -r
    fixture_make_auto_dir
}

tearDown() {
    fixture_delete_auto_dir
}

test_auto_cd_dirs() {
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

test_auto_when_modifying_node_version_file() {
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

        echo -n >.node-version
        chnode_auto 2>/dev/null
        echo "3,$?,$CHNODE_ROOT"

        rm .node-version
        chnode_auto
        echo "4,$?,$CHNODE_ROOT"
    )

    local expected_roots
    expected_roots=$(cat <<END
0,0,
1,0,$CHNODE_NODES_DIR/node-8.1.0
2,1,$CHNODE_NODES_DIR/node-8.1.0
3,0,
4,0,
END
)

    assertEquals "$expected_roots" "$actual_roots"
}

test_auto_support_fuzzy_matching_in_version_file() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        echo node-8 >.node-version
        chnode_auto 2>&1
        echo "0,$?,$CHNODE_ROOT"

        echo 8.1.0 >.node-version
        chnode_auto 2>&1
        echo "1,$?,$CHNODE_ROOT"

        echo 8 >.node-version
        chnode_auto 2>&1
        echo "2,$?,$CHNODE_ROOT"
    )
    actual+=$'\n'

    local idx expected=''
    for (( idx=0; idx <= 2; idx+=1 )); do
        expected+="$idx,0,$CHNODE_NODES_DIR/node-8.1.0"$'\n'
    done

    assertEquals "$expected" "$actual"
}

test_auto_parse_first_line_of_version_file() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        printf 'node-8.1.0' >.node-version
        chnode_auto 2>&1
        echo "0,$?,$CHNODE_ROOT"

        printf 'node-8.1.0\n' >.node-version
        chnode_auto 2>&1
        echo "1,$?,$CHNODE_ROOT"

        printf 'node-8.1.0\r\n' >.node-version
        chnode_auto 2>&1
        echo "2,$?,$CHNODE_ROOT"

        printf 'node-8.1.0\r' >.node-version
        chnode_auto 2>&1
        echo "3,$?,$CHNODE_ROOT"

        printf ' \t node-8.1.0 \t \n' >.node-version
        chnode_auto 2>&1
        echo "4,$?,$CHNODE_ROOT"

        printf ' \t node-8.1.0 \t \r\n' >.node-version
        chnode_auto 2>&1
        echo "5,$?,$CHNODE_ROOT"

        printf ' \t 8.1.0 \t \r\n' >.node-version
        chnode_auto 2>&1
        echo "6,$?,$CHNODE_ROOT"

        printf ' \t v8.1.0 \t \r\n' >.node-version
        chnode_auto 2>&1
        echo "7,$?,$CHNODE_ROOT"

        printf ' \t v8 \t \r\n' >.node-version
        chnode_auto 2>&1
        echo "8,$?,$CHNODE_ROOT"

        printf "node-8.1.0\nnode-10.11.0" >.node-version
        chnode_auto 2>&1
        echo "9,$?,$CHNODE_ROOT"
    )
    actual+=$'\n'

    local idx expected=''
    for (( idx=0; idx <= 9; idx+=1 )); do
        expected+="$idx,0,$CHNODE_NODES_DIR/node-8.1.0"$'\n'
    done

    assertEquals "$expected" "$actual"
}

test_auto_trim_leading_v_only_if_followed_by_digit_when_parsing_version_file() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        echo vnode-8 >.node-version
        chnode_auto 2>&1
        printf "0,%d,%s\n\n" $? "$CHNODE_ROOT"

        echo v >.node-version
        chnode_auto 2>&1
        printf "1,%d,%s\n\n" $? "$CHNODE_ROOT"

        echo v8 >.node-version
        chnode_auto 2>&1
        printf "2,%d,%s\n\n" $? "$CHNODE_ROOT"

        echo v8.1 >.node-version
        chnode_auto 2>&1
        printf "3,%d,%s\n\n" $? "$CHNODE_ROOT"
    )

    local expected
    expected=$(cat <<END
chnode: unknown Node.js: vnode-8
0,1,

chnode: unknown Node.js: v
1,1,

2,0,$CHNODE_NODES_DIR/node-8.1.0

3,0,$CHNODE_NODES_DIR/node-8.1.0
END
)

    assertEquals "$expected" "$actual"
}

test_auto_ignore_version_file_when_first_line_is_empty() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        touch .node-version
        chnode_auto 2>&1
        echo "0,$?,$CHNODE_ROOT"

        echo >.node-version
        chnode_auto 2>&1
        echo "1,$?,$CHNODE_ROOT"

        printf '  \t ' >.node-version
        chnode_auto 2>&1
        echo "2,$?,$CHNODE_ROOT"

        printf '  \t \n' >.node-version
        chnode_auto 2>&1
        echo "3,$?,$CHNODE_ROOT"

        printf '\nnode-8\n' >.node-version
        chnode_auto 2>&1
        echo "4,$?,$CHNODE_ROOT"

        printf '\r\nnode-8\r\n' >.node-version
        chnode_auto 2>&1
        echo "5,$?,$CHNODE_ROOT"
    )
    actual+=$'\n'

    local idx expected=''
    for (( idx=0; idx <= 5; idx+=1 )); do
        expected+="$idx,0,"$'\n'
    done

    assertEquals "$expected" "$actual"
}

test_auto_read_version_file_when_symlink() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        mkdir sub1
        echo node-8.1.0 >sub1/.node-version

        mkdir sub2
        cd sub2 || exit
        ln -s ../sub1/.node-version .node-version

        chnode_auto 2>&1
        echo "$?,$CHNODE_ROOT"
    )

    local expected="0,$CHNODE_NODES_DIR/node-8.1.0"

    assertEquals "$expected" "$actual"
}

test_auto_ignore_version_file_when_directory() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit

        mkdir .node-version
        chnode_auto 2>&1
        echo "$?,$CHNODE_ROOT"
    )

    local expected="0,"

    assertEquals "$expected" "$actual"
}

test_auto_reset_when_chnode_is_called_before_chnode_auto() {
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

test_auto_print_error_once_when_unknown_node_version() {
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

test_auto_use_custom_node_version_filename() {
    local actual
    actual=$(
        cd "$__FIXTURE_AUTO_DIR" || exit
        echo "node-8.1.0" >.nvmrc
        # shellcheck disable=SC2034
        CHNODE_AUTO_VERSION_FILENAME=.nvmrc
        chnode_auto
        echo "$?,$CHNODE_ROOT"
    )

    local expected="0,$CHNODE_NODES_DIR/node-8.1.0"

    assertEquals "$expected" "$actual"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
