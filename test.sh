#!/bin/bash

set -x
echo $1
echo $2
echo $PWD

cd $2

if [ -f test.txt ]; then exit 5; fi;
