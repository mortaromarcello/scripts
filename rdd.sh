#/bin/sh

if [ "$(id -u)" != "0" ]; then
    echo "Solo utente root"
    exit
fi

if [ $# -lt 3 ]; then
    echo "$0 <host> <local disk> <remote disk>"
    exit
fi
USER="root"
HOST="$1"
LOCAL_HD="$2"
REMOTE_HD="$3"
ping -c 2 $HOST
if [ "$?" != "0" ]; then
    echo "host irraggiungibile"
    exit
fi

#ssh ${USER}@${HOST} "ls $3"
#echo $LOCAL_HD
echo "\nHost\t\t\t\t => $HOST\nHardDisk o immagine locale \t => $LOCAL_HD\nHard Disk remoto\t\t => $REMOTE_HD\n\n"
echo "ATTENZIONE!!! Verrà sovrascritto ogni cosa sul HARD DISK REMOTO!\n\nContinuo (si/no)?\n"
read RISPOSTA
if [ "$RISPOSTA" != "si" ]; then
    echo "Abortito."
    exit
fi

dd if=$LOCAL_HD bs=1M | ssh ${USER}@${HOST} dd of=$REMOTE_HD bs=1M
