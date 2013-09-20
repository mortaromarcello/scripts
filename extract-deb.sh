#!/bin/bash

if [ -z $1 ]; then
  echo "$0 <namefile.deb> [<data-dir>] [data-control>]"
  exit
fi

DATA="data"
CONTROL="control"

if [ ! -z $2 ]; then
  DATA=$2
fi
if [ ! - $3 ]; then
  CONTROL=$3
fi

ar vx $1
mkdir -p $DATA
tar -C $DATA -xzvf data.tar.gz
mkdir -p $CONTROL
tar -C $CONTROL -xzvf control.tar.gz

