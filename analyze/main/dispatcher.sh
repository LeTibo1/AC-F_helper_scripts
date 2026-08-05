#!/bin/bash

# global variables
HELP_MSG="For a list of valid commands enter 'send_inp -h'"

dispatch() {
	while [[ $# -gt 0 ]]; do
		case $1 in
			--help|-h)
				show_help
				return 2
				;;
			*)
				die "Unknown command: $1; $HELP_MSG"
				;;
		esac
	done

	verify_input || return 1
}

verify_input() {
	return 0
}
