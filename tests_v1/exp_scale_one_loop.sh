#!/bin/bash

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}


if [ "$#" -gt 5 ]; then
    echo "Usage: scale.sh [ nodesize1 nodesize2 ... nodesize5 ] (default/max 32)"
    echo " ERROR : TOO MANY ARGUMENTS"
    echo " Example -> bash scale.sh 2 4 8"
	exit
fi
if [ "$#" -eq 0 ]; then
    echo "Usage: scale.sh [ size1 size2 ... size5 ] (default/max 32)"
    echo " this program requires at least 1 argument "
	exit
fi

accepted_nodes=( 1 2 4 8 16 32 )

####### validate arguments

for SERVERNODE in "$@"; do
  containsElement $SERVERNODE ${accepted_nodes[@]}
  if [ $? -eq 1 ]; then
    echo "nodesizes must be 1,2,4,8,16, or 32"
    exit
  fi
done

echo "running experiment for these solrnode cluster sizes:"
for SERVERNODE in "$@"; do
  echo $SERVERNODE
done

######## VALIDATION COMPLETE



# load sugar
source /Users/dporter/projects/solrcloud/utils.sh
shopt -s expand_aliases

############

# ARCHIVE PREVIOUS EXPs
archive_prev
archive_fcts

############  BEGIN EXP  ###################

SHARDS=( 2 )
T1=1
STEP=5
TN=10

# Outer loop is servernode size, next loop is for shards and exp types, inner loops for threads
# required since changing any shard, replica, or SERVERNODE size requires a full reindex.
# deleting previous collections is also required since disk space is limited.
# economical insofar as if solrj and direct is requested then it will not need to reindex between those.
# - also, only restart zookeeper and solrcloud after completing all exp loops for servernode size.



for SERVERNODE in "$@"; do
  ###### restart zoo and solr ######

  # echo "deleting previous collections"
  # delete_collections

# temp solution for limited node resources
  if [ $SERVERNODE = "32" ]; then
    SERVERNODE="28"
  fi

  echo "starting experiment for clustersize -> $SERVERNODE"

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

# since this var is only used to delete logs, just keep at all 8
  LOADHOSTS=ssh_files/pssh_traffic_node_file_8

  # constraint -> shards are 1, 2, or 4

  for SHARD in ${SHARDS[@]}; do


    ######## EXP LOOP = r*s = 2(num of SERVERNODES) ##########

    # no fractional divison
    if [[ $SHARD -eq 4 ]] && [[ $SERVERNODE = '1' ]];then
      continue
    fi

    RF=$(((2*$SERVERNODE)/$SHARD))

    echo "checking if cores exist for reviews_rf$RF _s$SHARD _clustersize$SERVERNODE"
    echo "will create collection if cores do not exist"
    cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --tags exp_mode --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
    wait $!

    for t in `seq $T1 $STEP $TN`; do
      cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query direct --loop open
      wait $!
      sleep 2
    done

    ######## END ##########
  done
done
