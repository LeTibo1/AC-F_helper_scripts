#!/bin/bash

# ==========================================
# print functions
# ==========================================

print_calcs() {
	local time_stamp="$BASE/.log/.last_submit" files

	# setup time_stamp files
	mkdir -p "$BASE/.log/"
	local init_time_stamp=1782086400
	[[ ! -f  "$time_stamp" ]] && echo "$init_time_stamp" > "$time_stamp"

	local ts=$(cat "$time_stamp")
	local count_done=0 count_fail=0 rc=0 result=""
	while IFS= read -r f; do
		case $PRINT_MODE in
			0)
				mtime=$(stat -c "%Y" "$f")
				[[ "$ts" -gt "$mtime" ]] && continue
				;;
			1)
				;;
		esac

		info "${BOLD_BLUE}$f${RESET}"
		if [[ "$f" =~ (opt|sp|goat|nbo) ]]; then
			result="${BASH_REMATCH[1]}"
		fi
		rc=0
		print_status "$(check_status "$f" "$result")" "$f" || rc=$?
		if [[ $rc -eq 0 ]]; then
			count_done=$((count_done + 1))
		else
			count_fail=$((count_fail + 1))
		fi

		echo $SINGLE_LINE
	done < <(find "$CURRENT_DIR" -name "*.out" ! -name "*slurm*")

	info "Total calculations that are done: $count_done"
	info "Total calculations that have failed: $count_fail"
}

print_status() {
	local stat=$1
	local file="$2"

	case $stat in
		"no_convergence")
			warn "Geometry calculation has failed"
			;;
		"imaginary")
			warn "Imaginary modes have been found"
			grep '***imaginary mode***' "$file"
			;;
		"complete")
			return 0
			;;
		"pending")
			warn "Calculation has failed or is not finished yet"
	esac

	return 1
}
