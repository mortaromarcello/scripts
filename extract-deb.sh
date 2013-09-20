#!/bin/bash

if [ -z $1 ]; then
  echo "$0 <nomefile.deb>"
  exit
fi

ar vx $1
