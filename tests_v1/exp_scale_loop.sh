#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"
# load sugar
source /Users/dporter/projects/solrcloud/utils/utils.sh
source /Users/dporter/projects/solrcloud/utils/exp_helpers.sh


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
    echo "nodesizes must be 2,4,8,16, or 32"
    exit
  fi
done

PREFIXER=""
echo "running experiment for these solrnode cluster sizes:"
for SERVERNODE in "$@"; do
  PREFIXER="${PREFIXER}${SERVERNODE}_"
  echo $SERVERNODE
done
CHARTNAME=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 7; echo)
CHARTNAME="$(date +"%m-%d")::${PREFIXER}${CHARTNAME}"
######## VALIDATION COMPLETE

echo "chartname:"
echo $CHARTNAME

# ARCHIVE PREVIOUS EXPs (this shouldnt archive anything if done correctly so first wipe dir)
rm -rf /Users/dporter/projects/solrcloud/tests_v1/profiling_data/exp_results/*
archivePrev $CHARTNAME
archive_fcts

#########  EXP PARAMS

# constraint -> shards are 1, 2, or 4
SHARDS=( 1 )
QUERY="solrj"
RF_MULTIPLE=( 4 )
LOAD=4


# loop_args
T1=1
STEP=1
TN=8
#########  PARAMS END



for SERVERNODE in "$@"; do

  if [ $SERVERNODE -gt '4' ]; then
    LOAD=8
  fi

# since this var is only used to delete logs, just keep at all 8
  LOADHOSTS=~/projects/solrcloud/ssh_files/pssh_traffic_node_file_8

  for SHARD in ${SHARDS[@]}; do

    for RF_MULT in ${RF_MULTIPLE[@]}; do


      ######## EXP LOOP = r*s = 2(num of SERVERNODES) ##########

      # no fractional divison
      if [[ $SHARD -eq 4 ]] && [[ $SERVERNODE = '1' ]];then
        continue
      fi

      RF=$(($RF_MULT*$SERVERNODE))

      # zookeeper is going to be confused when startSolr is run since the last exp moved indexes to cloud... but its fine
      startSolr $SERVERNODE
      # begin_exp is going to either post to solr a new colleciton or pull down an existing one from aws
      play post_data_$SERVERNODE.yml --tags begin_exp --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
      wait $!
      #  need to restart since pulling index from aws most likely happened and solr (not zookeeper) needs to restart after that hack
      restartSolr $SERVERNODE
      play post_data_$SERVERNODE.yml --tags update_collection_configs --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"

# warm cache... will throw this away in the chart_all_full.py script
      cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t 1 -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query $QUERY --loop open --load $LOAD
      wait $!
      sleep 2
#  done

      for t in `seq $T1 $STEP $TN`; do
        # keep last log
        cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"
        cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $SERVERNODE --solrnum $SERVERNODE --query $QUERY --loop open --load $LOAD
        wait $!
        sleep 2
      done
  # need to call stopsolr it here since it needs to stop this exp explicitly before running a new one
      stopSolr $SERVERNODE
      wait $!
      sleep 2
      play post_data_$SERVERNODE.yml --tags aws_exp_reset --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
    done
  done
  archivePrev $CHARTNAME
  archive_fcts
done
python3 /Users/dporter/projects/solrcloud/chart/chart_all_full.py $QUERY $CHARTNAME
python3 /Users/dporter/projects/solrcloud/chart/chartit_error_bars.py $QUERY $CHARTNAME
zip -r "/Users/dporter/projects/solrcloud/chart/exp_html_out/_$CHARTNAME/exp_zip.zip" "/Users/dporter/projects/solrcloud/chart/exp_records/$CHARTNAME"
