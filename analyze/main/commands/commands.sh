#!/bin/bash

find_out() {
	# find output files
	find "$HOME" -type f -name "*.out" ! -name "slurm*" ! -name "*_atom50*"
}

check_success() {
	# has .out file successfully converged?
	local file="$1"
	local ctype=$2

	if [[ $ctype == "nbo" ]]; then
		if ! grep -q 'NBO analysis completed' "$file" ; then
			info "bad"
			echo -e "${BOLD_BLUE}$file${RESET}"
			warn "Calculation has failed or is not finished yet"
			return 2
		else
			return 0
		fi
	fi

	if ! grep -q '****ORCA TERMINATED NORMALLY****' "$file" ; then
		echo -e "${BOLD_BLUE}$file${RESET}"
		warn "Calculation has failed or is not finished yet"
		return 2
	fi

	if grep -q 'The optimization did not converge' "$file"; then
		echo -e "${BOLD_BLUE}$file${RESET}"
		warn "Geometry calculation has failed"
		return 2
	fi

	if grep -q '***imaginary mode***' "$file"; then
		echo -e "${BOLD_BLUE}$file${RESET}"
		warn "Imaginary modes have been found"
        grep '***imaginary mode***' "$file"
		return 2
	fi

	return 0 
}
