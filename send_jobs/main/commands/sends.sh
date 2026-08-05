#!/bin/bash

# ==========================================
# send input functions
# ==========================================

send_inputs() {
	# save time stamp of the day
	local submit_file="$BASE/.log/.last_submit"
	echo "$(date -d "today 00:00:00" +%s)" > "$submit_file"

	local ext
	case $CALC_MODE in
		0|1)
			ext="inp"
			;;
		2)
			ext="47"
			;;
		*)
			die "Unknown calculation mode"
			;;
	esac

	# get single inp files
	local files=()
	while IFS= read -r f; do
		files+=("$f")
	done < <(find_lone_file $ext)

	if [[ "${#files[@]}" -eq 0 ]]; then
		die "No single .$ext file was found"
	fi

	# run calculation for files
	for f in "${files[@]}"; do
		echo $SINGLE_LINE
		run_calc "$f"
	done
}

run_calc() {
	# run calculation for file
	local file="$1"
	shift

	local files_2stay=("*.xyz" "*.inp" "*.47" "*_orca_2nbo.log" "m2a.ini" "*.gbw" "*.molden")
	
	local cmd="" cluster="GG-cluster" path_file msg base_file
	if ! $IS_GG; then
		cmd="justus "
		cluster="justus"
	fi

	case $CALC_MODE in
		0|1)
			cmd+="runorca -v $VERSION -n $CORES"
			msg="RUNORCA STOPPED"
			;;
		2)
			cmd+="runnbo -v $NVERSION"
			msg="RUNnbo STOPPED!"
			;;
		*)
			warn "Unknown calculation mode: $CALC_MODE"
			;;
	esac
	cmd+=" -w $WT -r $RAM"
	
	path_file=$(dirname "$file")
	base_file=$(basename "$file")
	cd "$path_file"

	# start calculation
	info "Starting calculation on ${BLUE}$cluster${RESET} for file: $file ..."
	local tmpfile=$(mktemp)
	$cmd "$base_file" 2>&1 | tee "$tmpfile"

	if grep -q "$msg" "$tmpfile" || grep -q "No connection to Justus2!" "$tmpfile"; then
		local notfiles=()
		for f in "${files_2stay[@]}"; do
			notfiles+=("!" "-name" "$f")
		done

		find "$path_file" -maxdepth 1 -type f "${notfiles[@]}" -delete
	else
		info "Adding calculation to log.xlsx"
		python "$BASE/main/python/log.py" --file "$file" --cluster "$cluster"
	fi

	rm "$tmpfile"
	cd "$CURRENT_DIR"
}
