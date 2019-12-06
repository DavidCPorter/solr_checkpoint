#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"
# load sugar
source /Users/dporter/projects/solrcloud/tests_v1/exp_scale_loop_params.sh
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
EXP_HOME=/Users/dporter/projects/solrcloud/chart/exp_records
mkdir $EXP_HOME/$CHARTNAME
# ARCHIVE PREVIOUS EXPs (this shouldnt archive anything if done correctly so first wipe dir)
rm -rf /Users/dporter/projects/solrcloud/tests_v1/profiling_data/exp_results/*

for QUERY in ${QUERYS[@]}; do

  for SERVERNODE in "$@"; do
    # maybe restart zoo


    LOAD=$(getLoadNum $SERVERNODE)

  # since this var is only used to delete logs, just keep at all 8
    LOADHOSTS=~/projects/solrcloud/ssh_files/pssh_traffic_node_file_8

    for SHARD in ${SHARDS[@]}; do

      for RF_MULT in ${RF_MULTIPLE[@]}; do


        ######## EXP LOOP = r*s = 2(num of SERVERNODES) ##########

        RF=$(($RF_MULT*$SERVERNODE))

        # zookeeper is going to be confused when startSolr is run since the last exp moved indexes to cloud... but its fine
        startSolr $SERVERNODE

        # begin_exp is going to either post to solr a new colleciton or pull down an existing one from aws
        play post_data_$SERVERNODE.yml --tags begin_exp --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
        #  need to restart since pulling index from aws most likely happened and solr (not zookeeper) needs to restart after that hack
        restartSolr $SERVERNODE

        play post_data_$SERVERNODE.yml --tags update_collection_configs --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"
        sleep 2

        #  sfor solrj ... using chroot requires restart of solrj every time :/
        if [ $QUERY == "solrj" ]; then
          echo "waiting for solr..."
          sleep 3
          echo "restarting solrj.."

          restartSolrJ $SERVERNODE
          sleep 2
        fi

        PROCESSES=$SERVERNODE
        SOLRNUM=$SERVERNODE
          # scale each load up to servernode size then add a load node
        request_counter=0
        # remove previous dstatout
        pssh -h $PROJECT_HOME/ssh_files/pssh_solr_node_file --user $USER "rm ~/${QUERY}*"
        # dstat on each node
        for n in "${ALL_NODES[@]}";do
          nohup ssh $USER@$n "dstat -t --cpu --mem --disk --io --net --int --sys --swap --tcp --output ${QUERY}_${n}_dstat_traffic_gen.csv &" >/dev/null 2>&1 &
        done
        echo "cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -d 10 --solrnum $SOLRNUM --query $QUERY"

        for l in {1..8}; do
          for t in {1..2}; do

            request_counter=$(($request_counter+1))

            # keep last log
            cd ~/projects/solrcloud;pssh -l dporte7 -h $LOADHOSTS "echo ''>traffic_gen/traffic_gen.log"

            echo "cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $((16*$request_counter)) --solrnum $SOLRNUM --query $QUERY --loop open --load $l"

            cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${t} -d 10 -p $((16*$request_counter)) --solrnum $SOLRNUM --query $QUERY --loop open --load $l
            sleep 2
          done
        done

        for n in "${ALL_NODES[@]}";do
          ssh $USER@$n "pkill -f dstat" >/dev/null 2>&1 &
        done

        DSTAT_DIR="${PROJECT_HOME}/rf_${RF}_s${SHARD}_solrnum${SOLRNUM}_query${QUERY}"
        mkdir $DSTAT_DIR

        for n in "${ALL_NODES[@]}";do
          scp -r $USER@${n}:~/${QUERY}* $DSTAT_DIR
        done

        mv $DSTAT_DIR "/Users/dporter/projects/solrcloud/chart/exp_records/$CHARTNAME"


    # need to call stopsolr it here since it needs to stop this exp explicitly before running a new one
        stopSolr $SERVERNODE
        play post_data_$SERVERNODE.yml --tags aws_exp_reset --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"

      done
    done
    archivePrev $CHARTNAME

  done
  python3 /Users/dporter/projects/solrcloud/chart/chart_all_full.py $QUERY $CHARTNAME
  python3 /Users/dporter/projects/solrcloud/chart/chartit_error_bars.py $QUERY $CHARTNAME
  zip -r /Users/dporter/projects/solrcloud/chart/exp_html_out/_$CHARTNAME/exp_zip.zip /Users/dporter/projects/solrcloud/chart/exp_records/$CHARTNAME
done
