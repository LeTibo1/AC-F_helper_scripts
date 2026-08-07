#!/bin/bash

show_info() {
	declare -A calc_settings
	for mode in GG-Cluster Justus NBO; do
		case "$mode" in
			GG-Cluster) wt=$GWT; ram=$GRAM; nodes=$GCORES ;;
			Justus)     wt=$JWT; ram=$JRAM; nodes=$JCORES ;;
			NBO)        wt=$NWT; ram=$NRAM; nodes=$NCORES ;;
		esac
		calc_settings["${mode}:Walltime"]=$(convert_time "$wt")
		calc_settings["${mode}:RAM"]="${ram}M"
		calc_settings["${mode}:Cores"]="$nodes"
	done

	declare -A input_settings
	for mode in GOAT OPT SP NBO; do
		solvent="no"
		case "$mode" in
			GOAT) fn="$FUNCTIONAL_GOAT"; bs="$BASISSET_GOAT";;
			OPT)  fn="$FUNCTIONAL_OPT"; bs="$BASISSET_OPT";;
			SP)   fn="$FUNCTIONAL_SP"; bs="$BASISSET_SP"; solvent="yes";;
			NBO)  fn="$FUNCTIONAL_NBO"; bs="$BASISSET_NBO";;
		esac
		[[ -z "$bs" ]] && bs="-"
		input_settings["${mode}:Functional"]="${fn/ /-}"
		input_settings["${mode}:Basis Set"]="$bs"
		input_settings["${mode}:Solvent"]="$solvent"
	done

	echo $FANCY_LINE
	echo "Calculation Settings:"
	echo ""
	print_table calc_settings
	echo ""
	echo "Input Settings:"
	echo ""
	print_table input_settings
	echo ""
	echo "Charge = $CHARGE; Multiplicity = $MULT"
	echo $FANCY_LINE
}

print_table() {
	declare -n ref="$1"
	local col1=16 colx=12
	local line1=$(repeat "-" $col1) linex=$(repeat "-" $colx)
	local t=0.01

	local key rheader=() cheader=()
	for key in "${!ref[@]}"; do
		[[ "$key" != *:* ]] && die "Key names from table must be in this format - 'row:col'"
		[[ " ${rheader[*]} " == *" ${key%%:*} "* ]] || rheader+=("${key%%:*}")
		[[ " ${cheader[*]} " == *" ${key#*:} "* ]] || cheader+=("${key#*:}")
	done

	local format="%-${col1}s "
	local linexs=("$line1")
	local i
	for i in "${cheader[@]}"; do
		format+="%-${colx}s "
		linexs+=("$linex")
	done
	format="${format/% /$'\n'}"
	
	# print header + lines
	printf "$format" "" "${cheader[@]}"
	sleep $t
	printf "$format" "${linexs[@]}"
	sleep $t

	# print table
	local r c
	for r in "${rheader[@]}"; do
		local rows=()
		for c in "${cheader[@]}"; do
			rows+=("${ref[$r:$c]}")
		done
		printf "$format" "$r" "${rows[@]}"
		sleep $t
	done
}

convert_time() {
	local time="$1"
	local ds="" hs="" ms="" ss="" result

	if [[ "$time" == *-* ]]; then
		ds="${time%%-*}"
		time="${time#*-}"
	fi

	IFS=":" read -r a b c <<< "$time"
	
	if [[ -n "$c" ]]; then
		hs="$a"; ms="$b"; ss="$c"
	elif [[ -n "$b" ]]; then
		hs="$a"; ms="$b"
	elif [[ -n "$a" ]]; then
		hs="$a"
	elif [[ -n "$time" ]]; then
		hs=$(( time / 60))
		ms=$(( time % 60))
	elif [[ -n "$ds" ]]; then
		echo ""
		return 1
	fi

	[[ -n "$ds" && "$ds" != "0"  ]] && result+="${ds}d"
	[[ -n "$hs" && "$hs" != "00" ]] && result+="${hs}h"
	[[ -n "$ms" && "$ms" != "00" && "$ms" != "0" ]] && result+="${ms}m"
	[[ -n "$ss" && "$ss" != "00" ]] && result+="${ss}s"

	echo "$result"
}
