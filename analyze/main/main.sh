#!/bin/bash

main() {
	local outs=() rc ctype
	while IFS= read -r f; do
		if [[ "$f" =~ (opt|sp|goat|nbo) ]]; then
			ctype="${BASH_REMATCH[1]}"
		fi

		rc=0; check_success "$f" "$ctype" || rc=$?
		[[ $rc -eq 1 ]] && return 1
		[[ $rc -eq 2 ]] && continue

		outs+=("$f")
	done < <(find_out)

	echo "---------------------------------------------------------"

	info "Creating energies.xlsx ..."
	mkdir -p "$HOME/tables"
	python "$BASE/main/python/main.py" --files "${outs[@]}" || return 1
	info "energies.xlsx was successfully created"

	return 0
}
