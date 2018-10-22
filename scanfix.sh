#!/usr/bin/env bash
if [ ! $1 ]; then
    exit
fi
badblocks $1 > ./bad-blocks

fsck -l ./bad-blocks $1