#!/bin/bash
cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf profiling_data/exp_results ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf profiling_data/exp_results/*
cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf *.zip ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip

for i in `seq 1 5 50`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 4  -t ${i} -d 15 -p 16 --solrnum 32 --query solrj --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 10
done
for i in `seq 1 5 50`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 4  -t ${i} -d 15 -p 16 --solrnum 32 --query solrj --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 5 50`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 16  -t ${i} -d 15 -p 16 --solrnum 32 --query solrj --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
