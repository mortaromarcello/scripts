#!/bin/bash
#-----------------------------------------------------------------------
# bash script per eseguire comandi ad un determinato orario attraverso
# il comando at. Lo script creerà un file provvisorio "at-commands" in
# cui verranno memorizzati i comandi passati come parametri allo script.
# il primo parametro deve essere l'orario nel format at HH:MMam/pm, poi
# passare i comandi con i parametri (opzionali) facendo precedere ogni 
# comando da un numero sequenzale partendo da 1 nella forma:
# '1 comando param-1 param-2 param-n 2 comando param-1...'
# numeri arbitrari provocheranno una esecuzione imprevedibile.
# L'output dei comandi verrà memorizzato nel file di log log.txt
# Per aggiungere il carattere '"' ai parametri del comando usare '\"'
# Per aggiungere il carattere '\' usare '\\'
#-----------------------------------------------------------------------
if [ "$#" -lt 2 ]; then
  echo -e "Usage: $0 [hh:mm]am/pm <\"1 command-1 (optional parameters)\" \"2 command-2(optional parameters)\" \"n command-n (optional parameters)\">"
  exit
fi

declare -i count1
declare -i count2
# registra l'output della sequenza di comandi
LOG="./log.txt"
echo -e "Log $(date)"> $LOG
TIME=${1}
shift
rm -f ./at-commands
count1=1

while [ $# -gt 0 ]; do
  if [ "$1" = "$count1" ]; then
    shift
    count1=count1+1
  fi
  count2=1
  for a in $*; do
    if [ "$a" != "$count1" ];then
      if [ $count2 -eq 1 ];then
        PARAM="$a"
      else PARAM="$PARAM $a"
      fi
      shift
    else break
    fi
    count2=count2+1
  done
  cat >>./at-commands<<EOF
${PARAM} >> ${LOG} 2>&1
EOF
done
at -f ./at-commands $TIME
