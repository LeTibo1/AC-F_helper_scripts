#!/bin/bash

cm() {
	d="$1"
	if [[ ! -d "$d" ]]; then
		echo "Error: missing valid directory"
		return 1
	fi

	mkdir tmp
	mv *.* tmp
	mv "$d"/*.* ./
	rm -r "$d"
	mv tmp "$d"
}

cm "$1"
