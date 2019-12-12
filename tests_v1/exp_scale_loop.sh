#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"

# load sugar
source /Users/dporter/projects/solrcloud/utils/utils.sh
source /Users/dporter/projects/solrcloud/utils/exp_helpers.sh
source /Users/dporter/projects/solrcloud/utils/exp_scale_loop_params.sh

LOAD_SCRIPTS="$PROJ_HOME/tests_v1/traffic_gen"
TERMS="$PROJ_HOME/tests_v1/words.txt"


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

accepted_nodes=( 2 4 8 16 24 )

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

# echo "$LOAD_NODES"
# echo "LOAD_NODES = ${LOAD_NODES[1]}"
echo 'Copying python scripts and search terms to load machines'
play update_loadscripts.yml --extra-vars "scripts_path=$LOAD_SCRIPTS terms_path=$TERMS"

for QUERY in ${QUERYS[@]}; do

  for SERVERNODE in "$@"; do
    # maybe restart zoo


    LOAD=$(getLoadNum $LOAD)

    LOADHOSTS="$PROJ_HOME/ssh_files/pssh_traffic_node_file"

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
        # remove previous dstatout
        pssh -h $PROJ_HOME/ssh_files/pssh_all --user $USER "rm ~/*dstat.csv"
        # dstat on each node
        # nodecounter just makes it easier to know which node dstat file was
        node_counter=0
        for n in $ALL_NODES;do
          nohup ssh $USER@$n "dstat -t --cpu --mem --disk --io --net --int --sys --swap --tcp --output node${node_counter}_${n}_${QUERY}::rf${RF}_s${SHARD}_cluster${SOLRNUM}_dstat.csv &" >/dev/null 2>&1 &
          node_counter=$(($node_counter+1))
        done
        echo "cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -d 10 --solrnum $SOLRNUM --query $QUERY"

        # vars for loop for config experiment
        machines=0
        box_cores=16
        box_threads=2
        app_threads=2
        export incrementer=2
        export procs=$(($box_cores*$box_threads))
        for ((l=$incrementer; l<=$LOAD; l=$((l+$incrementer))));do
          machines=$(($machines+$incrementer))

          # keep last log
          cd ~/projects/solrcloud;pssh -l dporte7 -h "${LOADHOSTS}_${LOAD}" "echo ''>traffic_gen/traffic_gen.log"

          echo "cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $(($procs*$machines*$app_threads)) --solrnum $SOLRNUM --query $QUERY --loop open --load $l"

          cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $(($procs*$machines*$app_threads)) --solrnum $SOLRNUM --query $QUERY --loop open --load $l
          sleep 2
        done

        for n in $ALL_NODES;do
          ssh $USER@$n "pkill -f dstat" >/dev/null 2>&1 &
        done

        DSTAT_DIR="${PROJ_HOME}/rf_${RF}_s${SHARD}_solrnum${SOLRNUM}_query${QUERY}"
        mkdir $DSTAT_DIR

        for n in $ALL_NODES;do
          scp -r $USER@${n}:~/*dstat.csv $DSTAT_DIR
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
