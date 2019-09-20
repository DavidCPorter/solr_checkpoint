#!/bin/bash
for i in `seq 1 20`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -c 5 -t ${i} -d 20 -p 3 --query direct --loop open
  wait $!
  sleep 10
done
for i in `seq 1 20`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -c 5 -t 2 -d 20 -p $(($i * 3))  --query direct --loop open
  wait $!
  sleep 10
done
