#!/bin/bash

#==================================================
#    FILE:  setup_kg.sh
#
#    USAGE:  ./setup_kg.sh [validation-size] [sample-size]
#
#    DESCRIPTION: downloads kaggle files, extracts zip-files,
#                            creates directories, and moves files
#
#    AUTHOR:  Jonas Pettersson, j.g.f.pettersson@gmail.com
#    CREATED:  31/12/2016
#==================================================


#    FUNCTION:  mv_rand [source-dir] [sample-size] [target-dir]
#    DESCRIPTION: moves [sample-size] number of random files from
#                           [source-dir] to [target-dir]
function mv_rand {
    for i in $(seq 1 $2)
    do
        RANGE=`ls $1 | wc -l`
        rand_idx=$RANDOM
        let "rand_idx %= $RANGE"
        mv -i `echo $1$(ls $1 | head -$rand_idx | tail -1)` $3
        echo Moving data from $1 to $3
        echo -ne $i'\r'
    done
    echo -ne '\n'
}

#    FUNCTION:  cp_rand [source-dir] [sample-size] [target-dir]
#    DESCRIPTION: copies [sample-size] number of random files from
#                           [source-dir] to [target-dir]
function cp_rand {
    for i in $(seq 1 $2)
    do
        rand_idx=`echo "(($(ls $1 | wc -l) * $(python -c "import random; print(random.random())") / 1))" | bc`
        cp `echo $1$(ls $1 | head -$rand_idx | tail -1)` $3
        echo Copying data from $1 to $3
        echo -ne $i'\r'
    done
    echo -ne '\n'
}

set -e

if [ "$1" == "-h" ]; then
    echo usage: $0 validation-size sample-size
    exit 0
fi

if [ "$(ls -A ./)" ]; then
    read -n1 -p "Directory is not empty! Proceed? [y,n]" doit
    case $doit in
        y|Y) echo ;;
        n|N) echo; exit 0 ;;
        *) echo; exit 0 ;;
    esac
fi

if [ $# -lt 2 ]
then
    sampleSz=100
    echo sample-size set to 100
elif ! [ $2 -eq $2 2>/dev/null ]
then
    echo $2 is not a valid integer
        echo usage: $0 validation-size sample-size
    exit 1
else
    sampleSz=$2
fi

if [ $# -lt 1 ]
then
    validSz=1000
    echo validation-size set to 1000
elif ! [ $1 -eq $1 2>/dev/null ]
then
    echo $1 is not a valid integer
        echo usage: $0 validation-size sample-size
    exit 1
else
    validSz=$1
fi

# get files from Kaggle (see https://github.com/floydwch/kaggle-cli)
kg download

# unzip into test / train directories and delete zip-files
unzip -q test.zip
unzip -q train.zip
rm test.zip
rm train.zip

# create directory structure
mkdir -v valid
mkdir -v valid/cats
mkdir -v valid/dogs

mkdir -v sample
mkdir -v sample/train
mkdir -v sample/train/cats
mkdir -v sample/train/dogs
mkdir -v sample/valid
mkdir -v sample/valid/cats
mkdir -v sample/valid/dogs

mkdir -v train/cats
mkdir -v train/dogs

# move training data into separate directories according to class
mv train/cat*.jpg train/cats/
mv train/dog*.jpg train/dogs/

# move a set of validation data to validation directories
mv_rand train/cats/ $validSz valid/cats/
mv_rand train/dogs/ $validSz valid/dogs/

# copy a small set of data to sample directories
cp_rand train/cats/ $sampleSz sample/train/cats/
cp_rand train/dogs/ $sampleSz sample/train/dogs/

cp_rand train/cats/ $sampleSz sample/valid/cats/
cp_rand train/dogs/ $sampleSz sample/valid/dogs/

# print results
echo "train/cats/:" `ls train/cats/ | wc -l`
echo "valid/cats/:" `ls valid/cats/ | wc -l`
echo "train/dogs/:" `ls train/dogs/ | wc -l`
echo "valid/dogs/:" `ls valid/dogs/ | wc -l`

echo "sample/train/cats/:" `ls sample/train/cats/ | wc -l`
echo "sample/train/dogs/:" `ls sample/train/dogs/ | wc -l`
echo "sample/valid/cats/:" `ls sample/valid/cats/ | wc -l`
echo "sample/valid/dogs/:" `ls sample/valid/dogs/ | wc -l`

