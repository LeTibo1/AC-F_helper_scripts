#!/bin/bash

update_log() {
	info "Scanning pending calculations for completion..."
	local is_pending=false is_complete=false is_success=true
	# get all pending jobs
	while IFS="|" read -r path ctype cluster; do
		is_pending=true
		# absoluten Pfad bekommen
		f=$(find "$HOME" -ipath "*$path")

		# justus does not copy the .out file to the 
		# server during the calculation
		[[ $cluster == "justus" && -z "$f" ]] && continue

		if ! is_file "$f"; then
			echo -e "file: $BOLD_BLUE$f$RESET"
			warn "Problem with $0"
			warn "this is not a valid path"
			warn "maybe the calculation has not started yet"
			warn "please try again later"
			continue
		fi

		# check if job is finished
		local c_status=$(get_status "$(check_status "$f" "$ctype")")
		
		[[ $c_status == "pending" ]] && continue
		is_complete=true

		echo -e "${BOLD_BLUE}$f${RESET}"
		info "calculation done with status: $BOLD_WHITE$c_status$RESET\n"\
			"Updating log.xlsx ..."
		python "$BASE/main/python/update_log.py" --file "$f" --status "$c_status"
		[[ $? -ne 0 ]] && is_success=false
	done < <(python "$BASE/main/python/get_pending.py")

	if $is_pending; then
		if $is_complete; then
			if $is_success; then
				info "log.xlsx has been updated successfully :)"
			else
				warn "log.xlsx was not updated. Please verify the files"
			fi
		else
			warn "No pending calculation is completed :("
		fi
	else
		info "No pending calculation :)"
	fi
	echo $SINGLE_LINE
}

get_status() {
    local stat=$1

	case $stat in
		"complete")
			echo $stat
			;;
		"pending")
			echo $stat
			;;
		*)
			echo "failed"
			;;
	esac
}
