#!/bin/bash
ROOT_PARTITION="sda1"
USE_HOME="FALSE"
HOME_PARTITION=
FORMAT_HOME="FALSE"
DEBUG="TRUE"
DISTRO="distro"
INST_DRIVE="sda"
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
KEYBOARD="it"
HOSTNAME="debian"
ADD_GROUPS="cdrom,floppy,audio,dip,video,plugdev,fuse,scanner,bluetooth,netdev,android"
TIMEZONE="Europe/Rome"
SHELL_USER="/bin/bash"
INST_ROOT_DIRECTORY="/mnt/${DISTRO}"
TYPE_FS="ext4"
USER=
USER_PASSWORD=
CRYPT_PASSWORD=
CRYPT_ROOT_PASSWORD=

PARTITIONS="$(awk '{if ($4 ~ /[hs]d[a-z][1-9]/) print $4}' /proc/partitions)"
PART_ARRAY=($PARTITIONS)
length=$((${#PART_ARRAY[@]} - 1))
for (( i=0; i <= length; i++ )); do
  strtmp=${PART_ARRAY[$i]}
  [[ ${strtmp} = ${ROOT_PARTITION} ]] && partitionslist+="^"
  [[ $i -lt $length ]] && partitionslist+="${strtmp}"! || partitionslist+="${strtmp}";
done
DISKS="$(awk '{if (length($4)==3 && $4 ~ /[hs]d/) print $4}' /proc/partitions)"
DISKS_ARRAY=($DISKS)
length=$((${#DISKS_ARRAY[@]} - 1))
for (( i=0; i <= length; i++ )); do
  [[ $i -lt $length ]] && diskslist+="${DISKS_ARRAY[$i]}"! || diskslist+="${DISKS_ARRAY[$i]}"
done
SETTINGS=$(yad --form --image "dialog-question" --separator='\n' --quoted-output --title="Opzioni" --text="Opzioni modificabili. Il nome  utente e la password sono obbligatori" \
  --field="Nome distro:" "$DISTRO" \
  --field="Partizione di root:cb" "$partitionslist" \
  --field="Drive di installazione::cb" "$diskslist" \
  --field="Locale:" "$LOCALE" \
  --field="Lingua:" "$LANG" \
  --field="Tastiera:" "$KEYBOARD" \
  --field="Hostname:" "$HOSTNAME" \
  --field="Utente:" "$USER" \
  --field="Password::h" "$USER_PASSWORD" \
  --field="Gruppi utente:" "$ADD_GROUPS" \
  --field="Shell utente:" "$SHELL_USER" \
  --field="Partizione di home:chk" "$USE_HOME" \
  --field="Debuggare:chk" "$DEBUG"
)

function set_home_partition() {
  if [ $USE_HOME="TRUE" ]; then
    list=$(echo ${partitionslist//$ROOT_PARTITION!/})
    res=$(yad --form --image "dialog-question" --separator='\n' \
      --field="Partizione home:cb" "$list" \
      --field="Formattare lapartizione:chk" $FORMAT_HOME
    )
    arr=($res)
    HOME_PARTITION=${res[0]}
    FORMAT_HOME=${res[1]}
  fi
}
result=$SETTINGS
array_result=($result)
if [[ $result ]]; then
  DISTRO="${array_result[0]//\'/}";echo $DISTRO
  ROOT_PARTITION=${array_result[1]//\'/};echo $ROOT_PARTITION
  INST_DRIVE=${array_result[2]//\'/};echo $INST_DRIVE
  LOCALE="${array_result[3]//\'/} ${array_result[4]//\'/}"; echo $LOCALE
  LANG=${array_result[5]//\'/}; echo $LANG
  KEYBOARD=${array_result[6]//\'/}; echo $KEYBOARD
  HOSTNAME=${array_result[7]//\'/}; echo $HOSTNAME
  USER=${array_result[8]//\'/}; echo $USER
  USER_PASSWORD=${array_result[9]//\'/}; echo $USER_PASSWORD
  ADD_GROUPS=${array_result[10]//\'/}; echo $ADD_GROUPS
  SHELL_USER=${array_result[11]//\'/}; echo $SHELL_USER
  USE_HOME=${array_result[12]//\'/}; echo $USE_HOME
  DEBUG=${array_result[13]//\'/}; echo $DEBUG
fi

#echo $result
echo ${array_result[*]}
[ $USE_HOME = "TRUE" ] && set_home_partition
echo $HOME_PARTITION
echo $FORMAT_HOME
