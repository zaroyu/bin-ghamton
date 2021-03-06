#!/bin/bash

SEQUENTIAL=false
while getopts "s" OPTION; do
	case $OPTION in
	s)  
		SEQUENTIAL=true
		shift
		;;
	*)
		echo "Incorrect options provided"
		;;
	esac
done

file_to_label="${3}"
tmpfile=$(mktemp)

if ! "${SEQUENTIAL}" ; then
	cp "${file_to_label}" "$tmpfile" && gawk -v numions="${1}" -v ionelement="${2}" '
		FNR==NR{ionarray[$1]=$1;next} 
		/Direct/ {
			print; 
			for (i = 1; i <= numions; i++) {
				if (i in ionarray) {
					getline;
					printf "%s", $0;
					printf "%s\n", " # " ionelement " " ionarray[i];
				}
			}
		next}1' ion_list "$tmpfile" >"${file_to_label}"
else
	cp "${file_to_label}" "$tmpfile" && gawk -v numions="${1}" -v ionelement="${2}" '
		/Direct/ {
			print; 
			for (i = 1; i <= numions; i++) {
				getline;
				printf "%s", $0;
				printf "%s\n", " # " ionelement " " i;
			}
		next}1' "$tmpfile" >"${file_to_label}"
fi