#!/bin/bash

if [ "$1" == "-h" ]; then
    echo usage: $0 filenames predictions
    exit 0
fi

if [ $# -ne 2 ]
then
    echo usage: $0 filenames predictions
    exit 1
elif ! [ -f $1 & -f $2 ]
then
    echo $1 or $2 is not a valid filename
    echo usage: $0 filenames predictions
    exit 1
else
    FILE_NAMES=$1
    PREDICTS=$2
fi

cut -f2 -d'/' $FILE_NAMES | cut -f1 -d'.' > filenames_clean.csv
sed -r 's/\s+//g' $PREDICTS > predicts_clean.csv
paste -d',' filenames_clean.csv predicts_clean.csv > submission_tmp.csv
#echo "id,label" > submission.csv
sort -t',' -n submission_tmp.csv > submission.csv
rm -i submission_tmp.csv
rm -i filenames_clean.csv
rm -i predicts_clean.csv
head submission.csv
