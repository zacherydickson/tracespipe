#!/bin/bash
cat ../meta_data/meta_info.txt | tr ':' '\t' | awk '{ print $1}' > names_tmp_TRACES.tmp
mapfile -t NAMES < names_tmp_TRACES.tmp
#
rm -f names2_tmp_TRACES.tmp
#
printf "\t" > names3_tmp_TRACES.tmp;
#
for name in "${NAMES[@]}" #
  do
  printf "$name\t\t" >> names3_tmp_TRACES.tmp;
  done
printf "\n" >> names3_tmp_TRACES.tmp;
#
for name in "${NAMES[@]}"; do
  printf "../output_data/TRACES_results/REPORT_META_VIRAL_$name.txt " >> names2_tmp_TRACES.tmp
done

outFile="../output_data/TRACES_results/REPORT_META_VIRAL_ALL_SAMPLES.txt";
rm -f "$outFile"

cat names3_tmp_TRACES.tmp > "$outFile";
awk '
    BEGIN{OFS="\t"}
    (ARGIND == 1){ virus[FNR]=$1; nVirus=FNR; next}
    (FNR==1){smpl=ARGIND-1;nSmpl=ARGIND-1}
    {sim[FNR,smpl]=$1; id[FNR,smpl]=$2;}
    END{
        for(i=1;i<=nVirus;i++){
            s=virus[i];
            for(j=1;j<=nSmpl;j++){
                s = s"\t"sim[i,j]"\t"id[i,j]
            }
            print s
        }
    }
' viral_names.txt $(cat names2_tmp_TRACES.tmp) >> "$outFile"

rm -f names_tmp_TRACES.tmp names2_tmp_TRACES.tmp names3_tmp_TRACES.tmp
