#!/bin/bash
ORGAN=$1; shift
TopFile=$1; shift
#
RESULT=`cat $TopFile \
| grep -a -e "HBoV " -e "bocavirus isolate" -e "HBoV1"  \
| grep -a -e "human" -e "Human" \
| grep -a -e "omplete genome" -e "omplete_genome" \
| awk '{ if($3 > 0 && $2 > 4000 && $2 < 6000) print $3"\t"$4; }' \
| head -n 1 \
| awk '{ print $1"\t"$2;}' \
| sed "s/NC\_/NC-/" \
| tr '_' '\t' \
| awk '{ print $1"\t"$2;}'`;
if [ -z "$RESULT" ]
  then
  echo -e "-\t-";
  else
  echo "$RESULT" | sed "s/NC-/NC\_/"
  fi
