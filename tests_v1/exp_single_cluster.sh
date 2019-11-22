#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"
# load sugar
source /Users/dporter/projects/solrcloud/utils/utils.sh
# shopt -s expand_aliases
source /Users/dporter/projects/solrcloud/utils/exp_helpers.sh


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
  play solr_configure_1.yml --tags solr_start
  wait $!
  sleep 5
}

createInstances () {
  printf "\n\n"
  echo "running createInstances()"
  printf "\n\n"

    INSTANCES=$1

    for i in `seq $(($INSTANCES-1))`;do

      if [ $INSTANCES = "1" ];then
        echo "not creating additional instances"
        break
      fi


      echo "creating new dir for instance -> $CLOUDHOME/node__$i"
      pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "mkdir $CLOUDHOME/node__$i"
    done
    wait $!

    for i in `seq $(($INSTANCES-1))`;do
      if [ $INSTANCES = '1' ];then
        break
      fi
      echo "copying config files to $CLOUDHOME/node__$i/"
      pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "cp -rf $CLOUDHOME/solr-8_0/solr/server/solr $CLOUDHOME/node__$i/"
    done
    wait $!

    for i in `seq $(($INSTANCES-1))`;do
      if [ $INSTANCES = '1' ];then
        break
      fi
      printf "\n launching:"
      echo "node__$i/solr -p 99$i$i"
      # should we nohup here?
      pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "bash ~/solr-8_0/solr/bin/solr start -cloud -q -s ~/node__$i/solr -p 99$i$i -Dhost=10.10.1.1"
      printf "\n done \n"
    done

    # runsolrj
    wait $!
    sleep 5
}

resetExperiment () {
  printf "\n\n"
  echo "resetting experiment..."
  delete_collections 8983
  sleep 5
  # clear slate for new index and solrcluster
  echo "wiping ancillary instances"
  wipeInstances
  wait $!
  sleep 5

  force_delete_single
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


if [ "$#" -gt 4 ]; then
    echo "Usage: exp_single_cluster.sh [ nodesize1 nodesize2 ... nodesize5 ] (default/max 32)"
    echo " ERROR : TOO MANY ARGUMENTS"
    echo " Example -> bash scale.sh 2 4 8"
	exit
fi
if [ "$#" -eq 0 ]; then
    echo "Usage: scale.sh [ size1 size2 ... size5 ] (default/max 32)"
    echo " this program requires at least 1 argument "
    echo "be sure to adjust shard, replica, loop_args, and Query args in this script and enable optional helper functions"
	exit
fi

accepted_instances=( 1 2 4 8 )



for instance in "$@"; do
  containsElement $instance ${accepted_instances[@]}
  if [ $? -eq 1 ]; then
    echo "nodesizes must be 1,2,4, or 8"
    exit
  fi
done

echo "running experiment for these solrnode cluster sizes:"
for instance in "$@"; do
  echo $instance
done

echo "running experiment for single node clustersize"




############

# ARCHIVE PREVIOUS EXPs
archive_prev
archive_fcts


############  BEGIN EXP  ###################

#########  PARAMS

SHARDS=( 1 )
QUERY="solrj"
RF=4
secondRF=2



# loop_args
T1=1
STEP=1
TN=20

#########  PARAMS END


# Outer loop is $INSTANCES size, next loop is for shards and exp types, inner loops for threads
# required since changing any shard, replica, or $INSTANCES size requires a full reindex.
# deleting previous collections is also required since disk space is limited.
# economical insofar as if solrj and direct is requested then it will not need to reindex between those.
# - also, only restart zookeeper and solrcloud after completing all exp loops for $INSTANCES size.



for INSTANCES in "$@"; do

############# OPTIONAL HELPER FUNCTIONS ###################

  # resetExperiment
  # restartSolrZoo
  restartSolrJ

  # instance -1 becuase ansible already launched a single instance and we are just adding nodes to that cluster
  # createInstances $INSTANCES

############# OPTIONAL HELPER FUNCTIONS DONE ###################


  # since this var is only used to delete logs, just keep at all 8
  LOADHOSTS=ssh_files/pssh_traffic_node_file_8

  # constraint -> shards are 1, 2, or 4

  for SHARD in ${SHARDS[@]}; do
    echo "starting experiment for clustersize -> reviews_rf$RF _s$SHARD _clustersize9$INSTANCES"

    ######## EXP LOOP = r*s = 2(num of $INSTANCESS) ##########

    # no fractional divison
    RF=4

 # to save 20 min i prefixed 9 to clustersize of INSTANCE so we dont use real cloud clusters collections (we limit accepted_instances to 8 so parsing still works)
    echo "checking if cores exist for reviews_rf$RF _s$SHARD _clustersize9$INSTANCES"
    echo "will create collection if cores do not exist and update the cache configs"
    play post_data.yml --tags exp_mode --extra-vars "replicas=$RF shards=$SHARD clustersize=9$INSTANCES"
    wait $!

    for t in `seq $T1 $STEP $TN`; do
      # keep last log
      cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
      cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest_single.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $INSTANCES --solrnum $INSTANCES --query $QUERY --loop open --instances $INSTANCES
      wait $!
      sleep 2
      singlelogs > ./solr-log.txt
    done

    # cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
    # delete_collections 9911
    # wait $!
    # sleep 8
    # clearout

    ######## END ##########



    ######## EXP LOOP = r*s = 1(num of $INSTANCESS) ##########

  #   secondRF=2
  #
  # # this should always create upload again.
  #   echo "checking if cores exist for reviews_rf$RF _s$SHARD _clustersize9$INSTANCES"
  #   echo "will create collection if cores do not exist"
  #   cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --tags exp_mode --extra-vars "replicas=$RF shards=$SHARD clustersize=9$INSTANCES"
  #   wait $!
  #
  #   for t in `seq $T1 $STEP $TN`; do
  #     # keep last log
  #     cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
  #     cd ~/projects/solrcloud/tests_v1; bash runtest_single.sh traffic_gen words.txt --user dporte7 -rf $secondRF -s $SHARD -t ${t} -d 10 -p $INSTANCES --solrnum $INSTANCES --query $QUERY --loop open --instances $INSTANCES
  #     wait $!
  #     sleep 2
  #   done
  #
  #
  #   cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>/users/dporte7/solrclientserver/solrjoutput.txt"
  #   echo " need to delete cuz we are looping back to new shard for same instance size"
  #   delete_collection 9911
  #   wait $!
  #   printf "\n\n"
  #   echo "FINISHED INNER SHARD LOOP FOR INSTANCES = $INSTANCES && SHARDS = $SHARD"
  #   printf "\n\n"
  #   printf "\n\n"
  #   sleep 5
  #   clearout
    ######## END ##########

  done
  printf "\n\n"
  printf "\n\n"
  echo "FINISHED OUTER INSTANCE LOOP FOR INSTANCES = $INSTANCES "
  printf "\n\n"
  printf "\n\n"
  sleep 5

done
