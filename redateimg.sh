#!/bin/bash

### readonly variables
readonly cutoff="1980"
readonly beginning_of_time="198001010001"

### default variables
directory=""
file_extensions="png,jpeg,jpg"

# usage information
function usage {
	cat <<- END >&2
	USAGE: redateimg.sh [-h] [-d directory] [-e extensions]

	    -d directory   # directory to scan (eg. ".")
	    -e extensions  # file extensions   (eg. "png,jpeg,jpg")
	    -h             # this help message
END
	exit
}

# set file update date to creation date
function redate {
	local file="$1"

	# get metadata creation date and format
	date="$(mdls -name kMDItemContentCreationDate "$file" | \
		awk '{gsub("-",""); gsub(":",""); print $3 substr($4, 1, 4)}')"
	echo "$date"

	# check year is after 'beginning of time'
	year="${date:0:4}"
	if [ "$year" -lt "$cutoff" ]; then
		touch -t "$beginning_of_time" "$file"
	else
		touch -t $date $file
	fi
}

### process options
while getopts d:e:h opt
do
	case "$opt" in
		d) directory="$OPTARG" ;;
		e) file_extensions="$OPTARG" ;;
		h) usage ;;
	esac
done
# separate file extensions list into array
IFS=', ' read -ra file_extensions <<< "$file_extensions"

# check directory exists
if [ ! -d "$directory" ]; then
	usage
	exit 1
fi

# check mdls is installed
if [ mdls ]; then
	echo 'mdls program is required to get meta data from files'
	exit 2
fi

# loop through file with chosen extensions
for extension in "${file_extensions[@]}"; do
	# loop file in directory
	for file in "$directory"/*."$extension"; do
		# check file exists
		if [ -e "$file" ]; then
			# update file date
			redate "$file"
		fi
	done
done

