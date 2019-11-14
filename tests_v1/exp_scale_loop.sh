#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"
# load sugar
source /Users/dporter/projects/solrcloud/utils.sh

restartSolrZoo () {
  printf "\n\n"
  echo "restarting zookeeper and solr "
  printf "\n\n"

  play solr_configure.yml --tags solr_stop
  wait $!
  sleep 5

  play zoo_configure.yml --tags zoo_stop
  wait $!
  sleep 5


  play zoo_configure.yml --tags zoo_start
  wait $!
  sleep 5
  play solr_configure_$1.yml --tags solr_start
  wait $!
  sleep 5
}


resetExperiment () {
  printf "\n\n"
  echo "resetting experiment..."
  delete_collections 8983
  sleep 5

}


restartSolrJ () {
  echo "restarting SOLRJ"
  printf "\n\n"
  echo "stopping SOLRJ"
  killsolrj
  wait $!
  sleep 6

  printf "\n\n"
  echo "starting SOLRJ"
  printf "\n\n"
  runsolrj
  wait $!
  sleep 4

}




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

accepted_nodes=( 2 4 8 16 32 )

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
# source /Users/dporter/projects/solrcloud/utils.sh
# shopt -s expand_aliases

############

# ARCHIVE PREVIOUS EXPs
archive_prev
archive_fcts

#########  PARAMS

SHARDS=( 1 2 )
QUERY="direct"
RF=4
secondRF=2


# loop_args
T1=1
STEP=1
TN=8

#########  PARAMS END

# Outer loop is servernode size, next loop is for shards and exp types, inner loops for threads
# required since changing any shard, replica, or SERVERNODE size requires a full reindex.
# deleting previous collections is also required since disk space is limited.
# economical insofar as if solrj and direct is requested then it will not need to reindex between those.
# - also, only restart zookeeper and solrcloud after completing all exp loops for servernode size.



for SERVERNODE in "$@"; do

  ############# OPTIONAL HELPER FUNCTIONS ###################

    resetExperiment
    restartSolrZoo $SERVERNODE
    # restartSolrJ

    # instance -1 becuase ansible already launched a single instance and we are just adding nodes to that cluster
    # createInstances $INSTANCES

  ############# OPTIONAL HELPER FUNCTIONS DONE ###################



# since this var is only used to delete logs, just keep at all 8
  LOADHOSTS=ssh_files/pssh_traffic_node_file_8

  # constraint -> shards are 1, 2, or 4

  for SHARD in ${SHARDS[@]}; do


    ######## EXP LOOP = r*s = 2(num of SERVERNODES) ##########

    # no fractional divison
    if [[ $SHARD -eq 4 ]] && [[ $SERVERNODE = '1' ]];then
      continue
    fi

    RF=$(((4*$SERVERNODE)/$SHARD))

    echo "checking if cores exist for reviews_rf$RF _s$SHARD _clustersize$SERVERNODE"
    echo "will create collection if cores do not exist"
    play post_data.yml --tags exp_mode --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
    wait $!

    for t in `seq $T1 $STEP $TN`; do
      # keep last log
      cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
      cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query $QUERY --loop open
      wait $!
      sleep 2
    done

    # cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
    # delete_collections
    # wait $!
    # sleep 8
    # clearout

    ######## END ##########



    ######## EXP LOOP = r*s = 1(num of SERVERNODES) ##########

    # no fractional divison
    # if [[ $SHARD -eq 4 ]] && [[ $SERVERNODE = '1' || $SERVERNODE = '2' ]] ;then
    #   continue
    # fi
    #
    # RF=$(($SERVERNODE/$SHARD))
    # echo "checking if cores exist for reviews_rf$RF _s$SHARD _clustersize$SERVERNODE"
    # echo "will create collection if cores do not exist"
    # cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --tags exp_mode --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
    # wait $!
    #
    # for t in `seq $T1 $STEP $TN`; do
    #   # keep last log
    #   cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
    #   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query $QUERY --loop open
    #   wait $!
    #   sleep 2
    # done
    #
    # cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
    # wait $!
    # sleep 8
    # clearout
    ######## END ##########

  done
done
