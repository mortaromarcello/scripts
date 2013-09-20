#!/usr/bash

if [ -z $1 ]; then
  echo "$0 <namefile.deb>"
  exit
fi
if [ -e data.tar.gz ] && [ -e control.tar.gz ]; then
  if [ ! -e debian-binary ]; then
    echo 2.0 > debian-binary
  fi
  ar rcs $1 debian-binary data.tar.gz control.tar.gz
elif
  echo "data.tar.gz or control.tar.gz missing."
fi
