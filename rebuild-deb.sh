#!/usr/bash

if [ -z $1 ]; then
  echo "$0 <namefile.deb>"
  exit
fi

ar rcs $1 debian-binary data.tar.gz control.tar.gz
