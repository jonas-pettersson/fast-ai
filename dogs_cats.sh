#!/bin/bash

if [ "$1" == "-h" ]; then
    echo usage: $0 image_file
    exit 0
fi

if [ $# -ne 1 ]
then
    echo usage: $0 image_file
    exit 1
elif ! [ -f $1 ]
then
    echo $1 is not a valid filename
    echo usage: $0 image_file
    exit 1
else
    imgFile=$1
fi

python dogs_cats.py $imgFile
