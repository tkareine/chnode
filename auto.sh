unset NODE_AUTO_VERSION

function chnode_auto() {
	local dir="$PWD/" version

	until [[ -z "$dir" ]]; do
		dir="${dir%/*}"

		if { read -r version <"$dir/.node-version"; } 2>/dev/null || [[ -n "$version" ]]; then
			version="${version%%[[:space:]]}"

			if [[ "$version" == "$node_AUTO_VERSION" ]]; then return
			else
				node_AUTO_VERSION="$version"
				chnode "$version"
				return $?
			fi
		fi
	done

	if [[ -n "$NODE_AUTO_VERSION" ]]; then
		chnode_reset
		unset NODE_AUTO_VERSION
	fi
}

if [[ -n "$ZSH_VERSION" ]]; then
	if [[ ! "$preexec_functions" == *chnode_auto* ]]; then
		preexec_functions+=("chnode_auto")
	fi
elif [[ -n "$BASH_VERSION" ]]; then
	trap '[[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]] && chnode_auto' DEBUG
fi
