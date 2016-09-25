#!/bin/bash

set -x
#(
echo $1
echo $2
echo $PWD

cd $2

if [ -f "$2/log_$1.txt" ]; then rm "$2/log_$1.txt"; fi;
if [ -f test.txt ]; then exit 5; fi;
#)  2>&1 | tee -a "$2/log_$1.txt"
