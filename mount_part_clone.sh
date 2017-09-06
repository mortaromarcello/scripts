#!/usr/bin/env bash
if [ -z $1 ] || [ -z $2 ]; then
    echo "Error"
    exit -1
fi

sudo cat $1 | sudo gzip -d -c | sudo partclone.restore -W -C -s - -O $2
#sudo gzip -v -d -c $1 > tmp.unzipped
#if [ -e tmp.unzipped ]; then
#    sudo partclone.restore -W -C -s tmp.unzipped -O $2
#    if [ -e $2 ]; then
#        sudo rm -f tmp.unzipped
#    fi
#else
#    echo "Error"
#    exit -1
#fi
