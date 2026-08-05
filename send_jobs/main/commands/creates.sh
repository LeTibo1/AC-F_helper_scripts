#!/bin/bash

# ==========================================
# create input functions
# ==========================================

create_input() {
	# create opt input files
	case $CREATE_MODE in
		1)
			create_opt || return 1
			;;
		2)
			create_sp || return 1
			;;
		3)
			create_goat || return 1
			;;
		4)
			create_nbo || return 1
			;;
		*)
			die "Unknown Calculation mode"
			;;
	esac
}

create_sp() {
	# dirs with parent dir of each opt
	local dirs=()
	while IFS= read -r f; do
		local dir=$(dirname "$f")
		dirs+=("$dir")
	done < <(find "$CURRENT_DIR" -type d -name "opt")

	for d in "${dirs[@]}"; do
		# only continues if /sp does not exist or is empty
		if is_dir "$d/sp"; then
			local count=$(find "$d/sp" -maxdepth 1 -type f | wc -l)
			[[ $count -ne 0 ]] && continue
		fi

		# check for neg. frequencies
		local is_neg=false
		while IFS= read -r f; do
			if grep -q '***imaginary mode***' "$f"; then
				warn "$f"
				warn "Skipping sp calculation because of neg. frequencies"
				is_neg=true
			fi
		done < <(find "$d/opt" -maxdepth 1 -name "*.out" ! -name "*slurm*")
		$is_neg && continue

		mkdir -p "$d/sp"

		# find .xyz files in opt
 		local files=()
		while IFS= read -r f; do
			files+=("$f")
		done < <(find "$d/opt" -maxdepth 1 -type f ! -name "*trj*" -name "*.xyz")
		[[ "${#files[@]}" -ne 1 ]] && continue

		# copy .xyz file from opt to sp
		local base=$(basename "${files[0]}" .xyz)
		inp="$d/sp/$base.inp"
		cp "${files[0]}" "$inp"

		info "Creating $inp"
 		xyz_2inp "$inp"
		echo "$SINGLE_LINE" >&2
	done
}

create_opt() {
	# dirs with opt
	local dirs=()
	while IFS= read -r f; do
		dirs+=("$f")
	done < <(find "$CURRENT_DIR" -type d -name "opt")
	array_empty "${#dirs[@]}" && die "No 'opt/' folder in this directory"

	for d in "${dirs[@]}"; do
		# check if opt/ exists
		if is_dir "$d"; then
			local count=$(find "$d" -maxdepth 1 -type f | wc -l)
			local info
			case $count in
				# if no file in opt -> goat
				0)
					local pardir=$(dirname "$d")
					local goatdir="$pardir/goat"
					# if no goat dir -> skip
					is_dir "$goatdir" || continue

					# search for .globalminimum.xyz file in goat
					local goatxyz=() file
					while IFS= read -r f; do
						goatxyz+=("$f")
					done < <(find "$goatdir" -name "*.globalminimum.xyz")
					case "${#goatxyz[@]}" in
						0)
							warn "No .globalminimum.xyz file was found in $goatdir"
							continue
							;;
						1)
							info="Converting .globalminimum.xyz file to new .inp file for $d"
							base=$(basename "${goatxyz[0]}" .globalminimum.xyz)
							file="$d/$base.xyz"
							cp "${goatxyz[0]}" "$file"
							;;
						*)
							warn "More than one .globalminimum.xyz file was found in $goatdir"
							continue
							;;
					esac
					;;
				1)
					file=$(find "$d" -maxdepth 1 -type f -name "*.xyz" ! -name "*trj*")
					[[ -z "$file" ]] && continue
					info="Converting $file to .inp file"
					;;
				*)
					continue
					;;
			esac
		else
			die "$d is not a valid directory"
		fi

		# move .xyz file to .inp
		local base=$(basename "$file" .xyz)
		inp="$d/$base.inp"
		mv "$file" "$inp"

		info "$info"
 		xyz_2inp "$inp"
		echo "$SINGLE_LINE" >&2
	done
}

create_goat() {
	# search for files in goat dirs
	# if zero files -> take .xyz file from opt
	# if only one xyz -> edit to inp
	# if more than one -> skip
	# => goat dir has to be created manually

	local pardir count optdir xyz base
	while IFS= read -r d; do
		pardir=$(dirname "$d")

		# count in goat
		count=$(find "$d" -maxdepth 1 -type f | wc -l)
		case $count in
			0)
				optdir="$pardir/opt"
				if ! is_dir "$optdir"; then
					warn "$optdir is no valid directory"
					continue
				fi

				local xyzs=()
				while IFS= read -r f; do
					xyzs+=("$f")
				done < <(find "$optdir" -maxdepth 1 -type f -name "*.xyz" ! -name "*_trj*")
				case "${#xyzs[@]}" in
					0)
						warn "Missing .xyz file in $optdir"
						continue
						;;
					1)
						;;
					*)
						warn "Too many .xyz files in $optdir"
						continue
						;;
				esac

				base=$(basename "${xyzs[0]}")
				xyz="$d/$base"
				cp "${xyzs[0]}" "$xyz"
				info "Converting ${xyzs[0]} to goat .inp"
				xyz_2inp "$inp" || return 1
				;;
			1)
				local xyz=$(find "$d" -maxdepth 1 -type f)
				[[ "${xyz##*.}" != "xyz" ]] && continue
				inp="${xyz/%xyz/inp}"
				mv "$xyz" "$inp"

				info "Creating $inp"
				xyz_2inp "$inp" || return 1
				;;
			*)
				continue
				;;
		esac

		echo "$SINGLE_LINE" >&2
	done < <(find "$CURRENT_DIR" -type d -name "goat")
}

create_nbo() {
	# copy .gbw file from sp/ dir to nbo/
	# convert to .47 file
	
	local d gbw nbo_gbw sp gbw_base count
	while IFS= read -r d; do
		# check if calculation already done
		check_output "$d" && continue
		# check if .47 already created
		count=$(find "$d" -maxdepth 1 -name "*.47" | wc -l)
		[[ $count -ne 0 ]] && continue

		sp=$(dirname "$d")
		sp="$sp/sp"
		if ! is_dir "$sp"; then
			warn "dir '$sp' is no valid directory"
			return 1
		fi

		count=$(find "$sp" -name "*.gbw" | wc -l)
		case $count in
			0)
				warn "No .gbw file in $sp\n   First run sp calculation"
				continue
				;;
			1)
				gbw=$(find "$sp" -name "*.gbw")
				if ! is_file "$gbw"; then
					warn "file '$gbw' is not a valid file"
					return 1
				fi
				gbw_base=$(basename "$gbw")
				;;
			*)
				warn "Too many .gbw files in $sp"
				continue
				;;
		esac

		# copy .gbw to nbo
		nbo_gbw="$d/$gbw_base"
		cp "$gbw" "$nbo_gbw"

		cd $(dirname "$nbo_gbw")
		info "Start converting $nbo_gbw to .47 file..."
		local log="${nbo_gbw%.*}_orca_2nbo.log"

		# convert .gbw to .47
		python3 "$BASE"/main/commands/orca_2nbo_wrapper.py "$gbw_base" "$log"

		if [[ $? -ne 0 ]]; then
			warn "orca_2nbo failed! Check $log for more information"
		else
			info "Converting completed!"
		fi

		echo "$SINGLE_LINE" >&2
		cd "$CURRENT_DIR"
	done < <(find "$CURRENT_DIR" -name nbo -type d)
}

xyz_2inp() {
	local file="$1"

	# remove first two lines
	sed -i '1,2d' "$file"

	# add input line
	local tmp=$(mktemp)
	echo "${INPUT_LINE[@]}" > "$tmp"

	# optional add solvent
	if $IS_INPUT_SOLVENT; then
		cat >> "$tmp" << EOF
%CPCM
smd true
smdsolvent "benzene"
end
EOF
	fi

	echo "* xyz $CHARGE $MULT" >> "$tmp"
	{ cat "$tmp"; cat "$file"; echo "*"; } > "${file}.new" && mv "${file}.new" "$file"
	rm "$tmp"
}

inp_2ginp() {
	local file="$1"

	sed -i '/^\*/,$!d' "$file"
	sed -i '1i! XTB2 GOAT' "$file"
}
