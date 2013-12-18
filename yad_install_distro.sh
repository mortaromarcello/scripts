#!/bin/bash
PARTITIONS="$(awk '{if ($4 ~ /[hs]d[a-z][1-9]/) print $4}' /proc/partitions)"
for item in $PARTITIONS; do 
  PART_ARRAY+=($item)
done
length=$((${#PART_ARRAY[@]} - 1))
for (( i=0; i <= length; i++ )); do
  [[ i -lt length ]] && partitionslist+="${PART_ARRAY[$i]}"! || partitionslist+="${PART_ARRAY[$i]}";
done
DISKS="$(awk '{if (length($4)==3 && $4 ~ /[hs]d/) print $4}' /proc/partitions)"
for item in $DISKS; do DISKS_ARRAY+=($item); done
length=$((${#DISKS_ARRAY[@]} - 1))
for (( i=0; i <= length; i++ )); do
  [[ i -lt length ]] && diskslist+="${DISKS_ARRAY[$i]}"! || 
  diskslist+="${DISKS_ARRAY[$i]}"
done
MOUNTS_SYSTEM=("/" "home" "var" "boot")
#echo $PARTITIONS $DISKS ${MOUNTS_SYSTEM[3]}
yad --form --separator='\n' --quoted-output \
  --field="Partizioni::cb" "$partitionslist" \
  --field="Dischi:cb" "$diskslist"
