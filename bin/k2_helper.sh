#!/bin/bash
set -e
set -u

sample_id=${1}

cut -f1-3,6-8 "${sample_id}".kraken2_minimizer.tax > "${sample_id}".kraken2.tax

awk -F "\t" -v OFS="\t" '($6=="S" || $6 =="U"){print $1,$2,$4,$5,$8}' "${sample_id}".kraken2_minimizer.tax | tr -s ' ' | sed 's/^ //g' > "${sample_id}".k2.s.tsv