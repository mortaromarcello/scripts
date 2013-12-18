#!/bin/bash
PARTITIONS=()
PARTITIONS="$(awk '{if ($4 ~ /[hs]d[a-z][1-9]/) print $4}' /proc/partitions)"

for item in $PARTITIONS; do 
  PART_ARRAY+=($item)
done
#partitionslist="Menu"!
length=$((${#PART_ARRAY[@]} - 1))
echo $length
last_par=${PART_ARRAY[${length}]}
echo $last_par
for item in $PARTITIONS; do
  #partitionslist+="^"
  [ ! $item=$last_par ] && partitionslist+="${item}"! || partitionslist+="${item}"
done
DISKS="$(awk '{if (length($4)==3 && $4 ~ /[hs]d/) print $4}' /proc/partitions)"
for item in $DISKS; do
  #diskslist+="^"
  diskslist+="${item}"!
done
MOUNTS_SYSTEM=("/" "home" "var" "boot")
#echo $PARTITIONS $DISKS ${MOUNTS_SYSTEM[3]}
yad --form --separator='\n' --quoted-output \
  --field="Partizioni::cb" "$partitionslist" \
  --field="Dischi:cb" "$diskslist"
