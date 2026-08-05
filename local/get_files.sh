#!/bin/bash

CURRENT_DIR="$PWD"
SCRIPT_PATH=$(dirname "$0")

if [[ "$CURRENT_DIR" != *opt ]]; then
	echo "You need to operate from an /opt directory"
	echo "Please change your directory to an /opt folder"
	exit
fi

files=()
while IFS= read -r f; do
	grep -q "\*\*\*imaginary mode\*\*\*" "$f" && continue
	files+=("$f")
done < <(find . -name "*.out" ! -name "slurm*" ! -name "*atom_*")

python3 "$SCRIPT_PATH"/nrg_dif.py --files "${files[@]}"
