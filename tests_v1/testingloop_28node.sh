#!/bin/bash

python3 /Users/dporter/projects/solrcloud/delete_collection.py
sleep 8
source /Users/dporter/projects/solrcloud/utils.sh

shopt -s expand_aliases

play zoo_configure.yml --tags zoo_stop
wait $!

sleep 5
play solr_configure.yml --tags solr_stop
wait $!

sleep 5
#
cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf profiling_data/exp_results ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf profiling_data/exp_results/*

cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf *.zip ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip


# outer loop iterates through 2,4,8,16,32
# next loop iterates shards 1,2,4
# inner most loop iterates threads 2,4,6 ... 12

# for j in `seq 3 5`; do
SERVERS=28
killsolrj
wait $1
sleep 4
play zoo_configure.yml --tags zoo_start
wait $!
sleep 5
play solr_configure_$SERVERS.yml --tags solr_start
wait $!
sleep 5
runsolrj
wait $!
sleep 5

SHARDS=1

#
# # s*r == SERVERS
# # constraint -> shards remain 1,2,4
# echo "checking if cores exist for reviews_ $SHARDS $SERVERS"
# cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --tags exp_mode --extra-vars "replicas=$SERVERS shards=$SHARDS clustersize=$SERVERS"
# wait $!
#
# for i in `seq 1 2 20`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest_8loads.sh traffic_gen words.txt --user dporte7 -rf $SERVERS -s $SHARDS -t ${i} -d 10 -p $SERVERS --solrnum $SERVERS --query direct --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 "echo ''>traffic_gen/traffic_gen.log"
#   sleep 8
# done
# cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
# sleep 2
#
#
# python3 /Users/dporter/projects/solrcloud/delete_collection.py
# wait $!
# sleep 15
# clearout

# 56
# s*r == SERVERS
# constraint -> shards remain 1,2,4
echo "checking if cores exist for reviews_ $SHARDS $SERVERS"
cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --tags exp_mode --extra-vars "replicas=56 shards=$SHARDS clustersize=$SERVERS"
wait $!

# s*r == SERVERS*2
# constraint -> shards remain 1,2,4
for i in `seq 1 2 20`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest_8loads.sh traffic_gen words.txt --user dporte7 -rf $((2*$SERVERS)) -s $SHARDS -t ${i} -d 10 -p $SERVERS --solrnum $SERVERS --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 "echo ''>traffic_gen/traffic_gen.log"
  sleep 8
done



  # for i in `seq 12 3 24`; do
  #   cd ~/projects/solrcloud/tests_v1; bash runtest_8loads.sh traffic_gen words.txt --user dporte7 -rf $((2*$SERVERS/$SHARDS)) -s $SHARDS -t ${i} -d 10 -p $SERVERS --solrnum $SERVERS --query solrj --loop open
  #   wait $!
  #   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  #   sleep 8
  # done
  # sleep 8
  # cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"

  # python3 /Users/dporter/projects/solrcloud/delete_collection.py
  # wait $!
  # sleep 15
  # clearout
  #
  # play zoo_configure.yml --tags zoo_stop
  # wait $!
  #
  # sleep 10
  # play solr_configure_$SERVERS.yml --tags solr_stop
  # #
  # wait $!
  # sleep 10
