#!/bin/bash

main() {
	# update log.xlsx
	update_log || return 1

	# create inp files
	if [[ $CREATE_MODE -ne 0 ]]; then
		create_input || return 1
	fi

	# print done calculations
	if $IS_PRINT; then
		print_calcs || return 1
		return 0
	fi

	# send input files
	if $IS_CALC; then
		send_inputs || return 1
	fi
}
