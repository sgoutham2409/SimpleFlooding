#!/bin/bash

rm -r csvFiles
mkdir csvFiles
for file in *.sca; do
    echo $file
    perl opp_sca2csv.pl -m '^FloodingNetwork\.node\[(?<module>[0-9]*)\]' \#numSent -f $file > ${file%.*}.csv
    #scavetool export $file -o ${file%.*}.csv -f "name(\#numSent) AND module(*node[0-9]*)"
    mv *.csv csvFiles
done
