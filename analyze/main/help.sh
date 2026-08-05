#!/bin/bash

MESSAGE=(
	"=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
	"This script analyzes all your data and creates EXCEL sheets :)"
	"=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
	"Usage: get_data [OPTIONS]"
	""
	"Options:"
	"  -h, --help          show this help message"
)

show_help() {
	local t=0.05
	for l in "${MESSAGE[@]}"; do
		echo "$l"
		sleep $t
	done
}
