#!/bin/bash


if [ "$#" -lt 2 ]; then
    echo "Usage: scale.sh [ size1 size2 size3 ... ] (default 32)"
	exit
fi

# load sugar
source /Users/dporter/projects/solrcloud/utils.sh
shopt -s expand_aliases

# for 8 or less solr nodes
LOADSIZE=8

delete_collections
sleep 8

############

# ARCHIVE PREVIOUS EXPs
archive_prev
archive_fcts

############  BEGIN EXP  ###################

SHARDS=( 1 2 4 )
T1=1
STEP=2
TN=24

# Outer loop is servernode size, next loop is for shards and exp types, inner loops for threads
# required since changing any shard, replica, or SERVERNODE size requires a full reindex.
# deleting previous collections is also required since disk space is limited.
# economical insofar as if solrj and direct is requested then it will not need to reindex between those.
# - also, only restart zookeeper and solrcloud after completing all exp loops for servernode size.

for SERVERNODE in "$@"; do
  ###### restart zoo and solr ######
  play zoo_configure.yml --tags zoo_stop
  wait $!
  sleep 5

  play solr_configure.yml --tags solr_stop
  wait $!
  sleep 5

  killsolrj
  wait $1
  sleep 4

  play zoo_configure.yml --tags zoo_start
  wait $!
  sleep 5
  play solr_configure_$SERVERNODE.yml --tags solr_start
  wait $!
  sleep 5

  runsolrj
  wait $!
  sleep 5
  ######### DONE ##############



  LOADHOSTS=ssh_files/pssh_traffic_node_file_8

  # constraint -> shards are 1, 2, or 4

  for SHARD in $SHARDS; do
    ######## EXP LOOP = r*s = 2(num of SERVERNODES) ##########

    # no fractional divison
    if [[ $SHARD -eq 4 ]] && [[ $SERVERNODE = '1' ]];then
      continue
    fi

    RF=$(((2*$SERVERNODE)/$SHARD))

    for t in `seq $T1 $STEP $TN`; do
      cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query direct --loop open
      wait $!
      cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
      sleep 2
    done
    cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
    sleep 2
    python3 /Users/dporter/projects/solrcloud/delete_collection.py
    wait $!
    sleep 8
    clearout

    ######## END ##########



    ######## EXP LOOP = r*s = 1(num of SERVERNODES) ##########

    if [[ $SHARD -eq 4 ]] && ($SERVERNODE = '1' || $SERVERNODE = '2') ]] ;then
      continue
    fi

    RF=$(($SERVERNODE/$SHARD))

    for t in `seq $T1 $STEP $TN`; do
      cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query direct --loop open
      wait $!
      cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
      sleep 2
    done

    cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
    sleep 2
    python3 /Users/dporter/projects/solrcloud/delete_collection.py
    wait $!
    sleep 8
    clearout
    ######## END ##########

  done
done
