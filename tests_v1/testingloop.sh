#!/bin/bash
for i in `seq 1 3 30`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -c 5 -t ${i} -d 20 -p 32 --query direct --loop open
  wait $!
  sleep 10
done
for j in `seq 2 2 10`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -c 5 -t $(($j * 3)) -d 20 -p $(($j * 3))  --query direct --loop open
  wait $!
  sleep 10
done
