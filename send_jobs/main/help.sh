#!/bin/bash

show_help() {
	local help_message=(
		$FANCY_LINE
		"This script is an automatic job sender :)"
		"It sends .inp files that are sitting lonely in a directory"	
		$FANCY_LINE
		"Usage: send_inp [OPTIONS]"
		""
		"Options:"
		"  -i, --info          display default calculation settings"
		""
		"  -j, --justus        run calculations on justus"
		""
		"  --runnbo            run nbo calculations (for .47 files)"
		""
		"  -p, --printcalc     print all calculations that have been"
		"                      finished since the last submit"
		"    optional for -p:"
		"      --ALL           print all calculations of all time"
		""
		"  -N, --nocalc        does not send calculations"
		""
		"Calculation modes:"
		"  -o, --optfreq       creates .inp files from .xyz files"
		"                      or from goat/*.globalminimum.xyz"
		""
		"  -s, --sp            prepares single point calc"
		"                      -> only works if opt was done"
		""
		"  -g, --goat          prepares goat calculation"
		"  --nbo               prepares nbo calculation (on justus)"
		"                      and run calculation afterwards"
		"    [INFO] nbo and goat calculations only work if .gbw (.xyz)"
		"           is given in a nbo/ (or goat/) dir or in a opt/ dir"
		"           -> nbo/goat dir have to be prepared in advance"
		"    optional:"
		"      --INPUT_LINE <orca input line>"
		"      --SOLVENT_OFF"
		"      --SOLVENT_ON (def for sp)"
		"      --CHARGE <charge> (def: 0, for neg. charge use mX)"
		"      --MULT <multiplicity> (def: 1)"
		"      --TIGHTOPT"
		"      --VERYTIGHTOPT"
		""
		"Calculation options:"
		"  -w, --walltime <day-hour:min:sec>"
		"  -c, --cores <number>"
		"  -r, --ram <ram>"
		""
		"  -h, --help          show this help message"
	)

	local t=0.01
	for l in "${help_message[@]}"; do
		echo "$l"
		sleep $t
	done
}
