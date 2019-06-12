#/bin/sh

if [ "$(id -u)" != "0" ]; then
    echo "Solo utente root"
    exit
fi

if [ $# -lt 3 ]; then
    echo "$0 <host> <local disk> <remote disk>"
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

#dd if=$LOCAL_HD bs=1M count=1 | ssh $USER@HOST dd of=$REMOTE_HD bs=1M
