
#!/bin/bash

for f in $1*; do
  name=$f
  date="$(mdls -name kMDItemContentCreationDate $name | awk '{gsub("-",""); gsub(":",""); print $3 substr($4, 1, 4)}')"
  echo $date
  year=${date:0:4}
  cutoff=1980
  if [ $year -lt $cutoff ]; then
    touch -t 198001010001 $f
  else
    touch -t $date $f
  fi
done
