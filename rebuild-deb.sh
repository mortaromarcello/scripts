#!/bin/bash

if [ -z $1 ]; then
  echo "$0 <namefile.deb> [<data-dir>] [<control-dir>]"
  exit
fi

DATA="data"
CONTROL="control"
if [ ! -e $2 ]; then
  DATA=$2
fi
if [ ! -e $3 ]; then
  CONTROL=$3
fi

if [ -d $DATA ]; then
  cd $DATA
  tar -czvf ../data.tar.gz *
  cd ../
else
  echo "$DATA not exist."
  exit
fi

if [ -d $CONTROL ]; then
  cd $CONTROL
  tar -czvf ../control.tar.gz *
  cd ../
else
  echo "$CONTROL not exist."
  exit
fi

if [ ! -e debian-binary ]; then
  echo 2.0 > debian-binary
fi
ar rcs $1 debian-binary data.tar.gz control.tar.gz
