#!/bin/bash

# ============================
# message functions
# ============================

die() {
	local msg="$1"

	echo -e "${RED}FATAL ERROR${RESET}: $msg" >&2
	exit 1
}

warn() {
	local msg="$1"
	echo -e "${YELLOW}WARNING${RESET}: $msg" >&2
}

info() {
	local msg="$1"
	echo -e "${GREEN}INFO${RESET}: $msg" >&2
}

# ============================
# file/dir functions
# ============================

check_dir() {
	local dir="$1"
	if [[ ! -d "$dir" ]]; then
		return 1
	fi
}

# ============================
# helper functions
# ============================

is_optsp() {
	local file="$1"

	pardir=$(basename "$(dirname "$file")")
	[[ "$pardir" == "opt" || "$pardir" == "sp" ]]
}
