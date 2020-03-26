#!/bin/bash

# check mdls is installed
if [ mdls ]; then
    echo 'mdls program is required to get meta data from files'
    exit 2
fi

# check program is executed correctly
if [ $# -eq 0 ] || [ ! -d $1 ]; then
    echo 'Execute: ./redateImg.sh <Directory>' 
    exit 1
fi

readonly CUTOFF=1980
readonly BEGINNING_OF_TIME=198001010001

# loop through all files in directory
# set date to metadata creation date if exists
for f in $1*; do
    name=$f
    date="$(mdls -name kMDItemContentCreationDate $name | awk '{gsub("-",""); gsub(":",""); print $3 substr($4, 1, 4)}')"
    echo $date
    # first 4 integers are year (date: index: len)
    year=${date:0:4}
    if [ $year -lt $CUTOFF ]; then
        touch -t $BEGINNING_OF_TIME $f
    else
        touch -t $date $f
    fi
done
