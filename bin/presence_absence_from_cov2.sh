#!/bin/bash

BAM=$1
WINDOWS_BED=$2

#/home/projects/14001280/software/samtools-1.11/samtools view -b  -f2 $BAM | coverageBed -b stdin -a $WINDOWS_BED  | awk '{if ($4>0) print $1"\t"1; else print $1"\t"0}' | sed -E 's/\|gi[^\t]+//' |  datamash -g 1 count 1 sum 2 | awk '{if ($3/$2>0.1) print $1"\tpresent"; else print $1"\tabsent"}'
samtools view -b  -f2 $BAM | \
coverageBed -b stdin -a $WINDOWS_BED  | \
awk '{if ($4>0) print $1"\t"1; else print $1"\t"0}' | \
sed -E 's/\|gi[^\t]+//' |  \
sort -k1,1 | \
awk '{if ($1 != prev) { if (NR > 1) print prev, count, sum; prev = $1; count = 0; sum = 0 } count++; sum += $2 } END { print prev, count, sum }' | \
#awk '{ count[$1]++; sum[$1] += $2 } END { for (key in count) print key, count[key], sum[key] }' | \
awk '{if ($3/$2>0.1) print $1"\tpresent"; else print $1"\tabsent"}'