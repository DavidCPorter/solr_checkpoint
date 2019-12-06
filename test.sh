#! /bin/bash

PROJECT_HOME='/Users/dporter/projects/solrcloud'

request_counter=0
mult=0
for l in {1..8}; do
  for t in {1..3}; do
    request_counter=$(($request_counter+1))
    # keep last log
    echo "cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 t= ${t} -p $((16*$request_counter)) --load $l"
    wait $!

  done
done
