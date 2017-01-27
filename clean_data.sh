#!/bin/bash

cut -f2 -d'/' filenames.csv | cut -f1 -d'.' >> filenames_clean.csv
sed -r 's/\s+//g' predicts.csv > predicts_clean.csv
paste -d',' filenames_clean.csv predicts_clean.csv > submission_tmp.csv
#echo "id,label" > submission.csv
sort -t',' -n submission_tmp.csv > submission.csv
#rm submission_tmp.csv
#rm filenames_clean.csv
#rm predicts_clean.csv
head submission.csv
