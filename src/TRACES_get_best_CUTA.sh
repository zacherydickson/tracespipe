#!/bin/bash
ORGAN=$1; shift
TopFile=$1; shift
#
RESULT=`cat $TopFile \
| grep -a -e "cutavirus" -e "Cutavirus" \
| grep -a -e "complete" \
| awk '{ if($3 > 0 && $2 > 3000 && $2 < 6000) print $3"\t"$4; }' \
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
