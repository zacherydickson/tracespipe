#!/bin/bash
#
declare -a INDIVIDUALS=('I1' 'I2' 'I3' 'I4' 'I5' 'I6' 'I7' 'I8' 'I9' 'I10' 'I11' 'I12' 'I13' 'I14' 'I15' 'I16' 'I17' 'I18' 'I19' 'I20' 'I21' 'I22' 'I23' 'I24' 'I25' 'I26' 'I27' 'I28' 'I29' 'I30' 'I31' 'I32' 'I33' 'I34' 'I35' 'I36' 'I37' 'I38' 'I40' 'I41' 'I42' 'I43' 'I44' 'I45' 'I46' 'I47' 'I48' 'I49' 'I50' 'I51' 'I52' 'I53' 'I54' 'IPOOL')
#
for x in "${INDIVIDUALS[@]}"
  do
  echo "Running I$x ...";
  cd novaseq_2/$x/tracespipe_template/src/ 
  ./TRACESPipe.sh --run-meta --run-mito --run-all-v-alig --run-hybrid
  cd ../../../../
  echo "Done!";
  done
#
