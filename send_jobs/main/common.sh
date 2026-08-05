#!/bin/bash

# line separator
SINGLE_LINE="--------------------------------------------------"
FANCY_LINE="=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

# ============================
# message functions
# ============================

die() {
	local msg="$*"

	echo -e "${BOLD_RED}FATAL ERROR${RESET}: $msg" >&2
	exit 1
}

warn() {
	local msg="$*"
	echo -e "${BOLD_YELLOW}WARNING${RESET}: $msg" >&2
}

info() {
	local msg="$*"
	echo -e "${BOLD_GREEN}INFO${RESET}: $msg" >&2
}

# ============================
# file/dir functions
# ============================

is_dir() {
	local dir="$1"
	[[ -d "$dir" ]]
}

is_file() {
	local dir="$1"
	[[ -f "$dir" ]]
}

is_empty() {
	local inp="$1"
	[[ -z "$inp" || "$inp" == -* ]]
}

array_empty() {
	local a=$1
	[[ $a -eq 0 ]]
}

# ============================
# helper functions
# ============================

repeat() {
	local char="$1" count="$2"
	printf '%*s' "$count" '' | tr ' ' "$char"
}

check_alone() {
	local file="$1"
	local file_path count

	file_path=$(dirname "$file")
	count=$(find "$file_path" -maxdepth 1 -type f | wc -l)
	[[ "$count" -gt 1 ]] && return 1
	return 0
}

check_output() {
	local fileordir="$1"
	local count dir

	if [[ -f $fileordir ]]; then
		dir=$(dirname "$fileordir")
	elif [[ -d $fileordir ]]; then
		dir=$fileordir
	fi

	count=$(find "$dir" -maxdepth 1 -type f \
		\( -name "*.out" -o -name "*slurm*" -o -name "*.job" -o -name "Running_with_ID_*" \) \
		| wc -l)
	[[ "$count" -eq 0 ]] && return 1
	return 0
}

find_lone_file() {
	# find files that are alone in a directory
	# takes one argument: extension of files
	local ext=$1
	[[ -z "$ext" ]] && return 1

	local files=()
	while IFS= read -r file; do
		files+=("$file")
	done < <(find "$CURRENT_DIR" -type f -name "*.$ext")

	for f in "${files[@]}"; do
		case "$ext" in
			inp)
				check_alone "$f" || continue
				echo "$f"
				;;
			47)
				check_output "$f" && continue
				echo "$f"
				;;
			*)
				die "The extension '$ext' is not valid"
		esac
	done
}

check_status() {
	local file="$1"
	local ctype=$2

	if [[ $ctype == "nbo" ]]; then
		if ! grep -q 'NBO analysis completed' "$file"; then
			echo "no_convergence"
			return 0
		else
			echo "complete"
			return 0
		fi
	fi
	if grep -q 'The optimization did not converge' "$file"; then
		echo "no_convergence"
		return 0
	fi
	if grep -q '***imaginary mode***' "$file"; then
		echo "imaginary"
		return 0
	fi
	if grep -q '****ORCA TERMINATED NORMALLY****' "$file"; then
		echo "complete"
		return 0
	elif grep -q 'Error :' "$file" || grep -q 'Aborting' "$file"; then
		echo "failed"
		return 0
	else
		echo "pending"
		return 0
	fi
}

is_module_loaded() {
    [[ ":$LOADEDMODULES:" == *":chem/orca/$VERSION:"* ]]
}

runorca() {
	/share/scripts/runorca "$@"
}

justus() {
	/share/scripts/gg-cluster/justus "$@"
}

runnbo() {
	/share/scripts/runnbo "$@"
}
