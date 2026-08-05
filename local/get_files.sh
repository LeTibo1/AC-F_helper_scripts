#!/bin/bash

CURRENT_DIR="$PWD"
SCRIPT_PATH="$HOME/Documents/Wichtig/Uni/Master_Forschis/Greb/scripts/local"

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
