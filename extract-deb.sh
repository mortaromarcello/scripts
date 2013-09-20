#!/bin/bash

if [ -z $1 ]; then
  echo "$0 <namefile.deb>"
  exit
fi

ar vx $1
