#!/bin/bash

# global variables
HELP_MSG="For a list of valid commands enter 'send_inp -h'"
IS_GG=true
# 0 = no create input, 1 = opt, 2 = sp, 3 = goat
CREATE_MODE=0
# 0 = sp/opt, 1 = goat, 2 = nbo
CALC_MODE=0
IS_CHANGE=false
IS_PRINT=false
IS_CALC=true
WT_SET=false
CORES_SET=false
RAM_SET=false
# 0 = current, 1 = all time
PRINT_MODE=0

dispatch() {
	while [[ $# -gt 0 ]]; do
		case $1 in
			--help|-h)
				show_help
				return 0
				;;
			--info|-i)
				show_info
				return 0
				;;
			--nocalc|-N)
				IS_CALC=false
				shift
				;;
			--runnbo)
				CALC_MODE=2
				IS_GG=false
				shift
				;;
			--justus|-j)
				IS_GG=false
				shift
				;;
			--optfreq|-o)
				CREATE_MODE=1
				INPUT_LINE=("${INPUT_LINE_OPT[@]}")
				shift
				;;
			--sp|-s)
				CREATE_MODE=2
				IS_INPUT_SOLVENT=true
				INPUT_LINE=("${INPUT_LINE_SP[@]}")
				shift
				;;
			--goat|-g)
				IS_GG=false
				CREATE_MODE=3
				CALC_MODE=1
				INPUT_LINE=("${INPUT_LINE_GOAT[@]}")
				shift
				;;
			--nbo)
				IS_GG=false
				CREATE_MODE=4
				CALC_MODE=2
				INPUT_LINE=("${INPUT_LINE_NBO[@]}")
				shift
				;;
			--SOLVENT_ON)
				IS_CHANGE=true
				IS_INPUT_SOLVENT=true
				shift
				;;
			--SOLVENT_OFF)
				IS_CHANGE=true
				IS_INPUT_SOLVENT=false
				shift
				;;
			--INPUT_LINE)
				IS_CHANGE=true
				shift
				is_empty "$1" && die "Missing input. $HELP_MSG"
				INPUT_LINE=()
				while ! is_empty "$1"; do
					INPUT_LINE+=("$1")
					shift
				done
				;;
			--CHARGE)
				IS_CHANGE=true
				shift
				is_empty "$1" && die "Missing charge. $HELP_MSG"
				CHARGE="${1/m/-}"
				shift
				;;
			--MULT)
				IS_CHANGE=true
				shift
				is_empty "$1" && die "Missing multiplicity. $HELP_MSG"
				MULT="$1"
				shift
				;;
			--TIGHTOPT)
				IS_CHANGE=true
				INPUT_LINE=("${INPUT_LINE_TIGHTOPT[@]}")
				shift
				;;
			--VERYTIGHTOPT)
				IS_CHANGE=true
				INPUT_LINE=("${INPUT_LINE_VERYTIGHTOPT[@]}")
				shift
				;;
			--walltime|-w)
				shift
				is_empty "$1" && die "Missing walltime. $HELP_MSG"
				WT="$1"
				WT_SET=true
				shift
				;;
			--cores|-c)
				shift
				is_empty "$1" && die "Missing cores. $HELP_MSG"
				CORES=$1
				CORES_SET=true
				shift
				;;
			--ram|-r)
				shift
				is_empty "$1" && die "Missing ram input. $HELP_MSG"
				RAM="$1"
				RAM_SET=true
				shift
				;;
			--printcalc|-p)
				IS_PRINT=true
				IS_CALC=false
				shift
				;;
			--ALL)
				PRINT_MODE=1
				shift
				;;
			*)
				die "Unknown command: $1; $HELP_MSG"
				;;
		esac
	done

	verify_input || return 1
	# run main
	main || return 1
}

verify_input() {
	case $CALC_MODE in
		0)
			if $IS_GG; then
				! $WT_SET && WT=$GGWT
				! $RAM_SET && RAM=$GGRAM
				! $CORES_SET && CORES=$GGCORES
			else
				! $WT_SET && WT=$JWT
				! $RAM_SET && RAM=$JRAM
				! $CORES_SET && CORES=$JCORES
			fi
			;;
		1)
			! $WT_SET && WT=$GWT
			! $RAM_SET && RAM=$GRAM
			! $CORES_SET && CORES=$GCORES
			;;
		2)
			if ! is_module_loaded; then
				warn "orca/$VERSION needs to be loaded once..."
				info "Command:   'module load chem/orca/$VERSION'"
				return 1
			fi

			! $WT_SET && WT=$NWT
			! $RAM_SET && RAM=$NRAM
			CORES=$NCORES
			;;
		*)
			warn "Unknown calculation mode: $CALC_MODE"
			return 1
			;;
	esac

	if $IS_CHANGE && [[ $CREATE_MODE == 0 ]]; then
		warn "You did change some input parameters without\n"\
			"        creating new .inp files. Did you forget to activate '-c'?"
	fi

	if [[ $PRINT_MODE -ne 0 ]] && ! $IS_PRINT; then
		warn "--ALL only has an affect for the printing option\n"\
			"        Did you forget to activate '-p'"
	fi

	return 0
}
