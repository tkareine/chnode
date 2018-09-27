# -*- sh-shell: bash; -*-

print_shell_info() {
    local version
    case "${SHELL##*/}" in
        bash)
            version=$BASH_VERSION
            ;;
        zsh)
            version=$ZSH_VERSION
            ;;
        *)
            version=unknown
            ;;
    esac

    printf "SHELL=%s (%s)" "$SHELL" "$version"
}
