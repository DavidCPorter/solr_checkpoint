#!/bin/bash

CLOUDHOME=/users/dporte7
export USER="dporte7"
export PROJ_HOME=$PROJ_HOME

# load sugar
source /Users/dporter/projects/solrcloud/utils/utils.sh
source /Users/dporter/projects/solrcloud/utils/exp_helpers.sh
source /Users/dporter/projects/solrcloud/utils/exp_scale_loop_params.sh

commence_dstat () {
  # remove previous dstatout
  QUERY=$1
  RF=$2
  SHARD=$3
  SOLRNUM=$4
  echo "dstat should not be running but killing just in case"
  pssh -h $PROJ_HOME/ssh_files/pssh_all --user $USER "pkill -f dstat"


  echo "removing prev dstat files"
  pssh -h $PROJ_HOME/ssh_files/pssh_all --user $USER "rm ~/*dstat.csv"
  # dstat on each node
  # nodecounter just makes it easier to know which node dstat file was
  node_counter=0


  echo "COMMENCE DSTAT ON ALL MACHINES..."
  printf "\n"


  ssh $USER@$n "pkill -f dstat" >/dev/null 2>&1 &

  for n in $ALL_NODES;do
    nohup ssh $USER@$n "dstat -t --cpu --mem --disk --io --net --int --sys --swap --tcp --output node${node_counter}_${n}_${QUERY}::rf${RF}_s${SHARD}_cluster${SOLRNUM}_dstat.csv &" >/dev/null 2>&1 &
    node_counter=$(($node_counter+1))
  done
  printf "\n"
  echo "DSTAT LIVE"
  printf "\n"
}

LOAD_SCRIPTS="$PROJ_HOME/tests_v1/traffic_gen"
TERMS="$PROJ_HOME/tests_v1/words.txt"
ENV_OUTPUT_FILE="$PROJ_HOME/env_output_file.txt"
touch $ENV_OUTPUT_FILE


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
printf "\n\n\n\n"
echo "******** STARTING FULL SCALING EXPERIEMENT **********"
printf "\n"
echo " SCALE EXP loop will measure performance of solrcloud with these cluster sizes:"
for SERVERNODE in "$@"; do
  PREFIXER="${PREFIXER}${SERVERNODE}_"
  echo $SERVERNODE
done
CHARTNAME=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 7; echo)
CHARTNAME="$(date +"%m-%d")::${PREFIXER}${CHARTNAME}"
######## VALIDATION COMPLETE
printf "\n\n\n"



# vars for loop for config experiment
box_cores=16
box_threads=1
app_threads=1
echo "SCALE EXP will increase outstanding query requests (LOAD) from $(($load_server_incrementer*$app_threads*$box_cores*$box_threads)) --->> $(($LOAD*$app_threads*$box_cores*$box_threads)) + $(($EXTRA_ITERS*16))"
echo "chartname:"
echo $CHARTNAME
EXP_HOME=/Users/dporter/projects/solrcloud/chart/exp_records
mkdir $EXP_HOME/$CHARTNAME
# ARCHIVE PREVIOUS EXPs (this shouldnt archive anything if done correctly so first wipe dir)
rm -rf $PROJ_HOME/tests_v1/profiling_data/exp_results/*
rm -rf $PROJ_HOME/tests_v1/profiling_data/proc_results/*
mkdir $PROJ_HOME/tests_v1/profiling_data/proc_results

# echo "$LOAD_NODES"
# echo "LOAD_NODES = ${LOAD_NODES[1]}"
if [ $copy_python_scripts == "yes" ]; then
  echo 'Copying python scripts and search terms to load machines'
  play update_loadscripts.yml --extra-vars "scripts_path=$LOAD_SCRIPTS terms_path=$TERMS"
fi

########## PRINT ENV TO ENV OUTPUT FILE ##########

LOAD=$(getLoadNum $LOAD)

echo "LOADNODES:::" > $ENV_OUTPUT_FILE
pssh -h $PROJ_HOME/ssh_files/pssh_traffic_node_file_$LOAD -P "lscpu | grep 'CPU(s)\|Thread(s)\|Core(s)\|Arch\|cache\|Socket(s)'" >> $ENV_OUTPUT_FILE
echo "********" >> $ENV_OUTPUT_FILE

echo "SOLR NODES:::" >> $ENV_OUTPUT_FILE
pssh -h $PROJ_HOME/ssh_files/pssh_solr_node_file -P "lscpu | grep 'CPU(s)\|Thread(s)\|Core(s)\|Arch\|cache\|Socket(s)'" >> $ENV_OUTPUT_FILE
echo "********" >> $ENV_OUTPUT_FILE

echo "NETWORK BANDWIDTH::: " >> $ENV_OUTPUT_FILE
pssh -h $PROJ_HOME/ssh_files/pssh_all -P "cat /sys/class/net/eno1d1/speed" >> $ENV_OUTPUT_FILE
echo "********" >> $ENV_OUTPUT_FILE

echo "RAM::: " >> $ENV_OUTPUT_FILE
pssh -h $PROJ_HOME/ssh_files/pssh_all -P "lshw -c memory | grep size" >> $ENV_OUTPUT_FILE
echo "********" >> $ENV_OUTPUT_FILE


for QUERY in ${QUERYS[@]}; do

  for SERVERNODE in "$@"; do
    # maybe restart zoo



    LOADHOSTS="$PROJ_HOME/ssh_files/pssh_traffic_node_file"

    for SHARD in ${SHARDS[@]}; do

      for RF_MULT in ${RF_MULTIPLE[@]}; do


        ######## EXP LOOP = r*s = 2(num of SERVERNODES) ##########

        RF=$(($RF_MULT*$SERVERNODE))
        # RF=$RF_MULT
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

        if [ "$DSTAT_SWITCH" = on ];then
          commence_dstat $QUERY $RF $SHARD $SOLRNUM
        fi

        # vars for loop for config experiment
        box_cores=16
        box_threads=1
        app_threads=1
        load_start=$load_start
        load_server_incrementer=$load_server_incrementer
        export procs=$(($box_cores*$box_threads))
        export SOLRJ_PORT_OVERRIDE=$SOLRJ_PORT_OVERRIDE
        export first_time=yes
        export M_LOAD=$LOAD
        export second_pass=0

        # warm cache
        cd ~/projects/solrcloud;pssh -l dporte7 -h "${LOADHOSTS}_${LOAD}" "echo ''>traffic_gen/traffic_gen.log"
        cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $(($procs*$M_LOAD*$app_threads)) --solrnum $SOLRNUM --query $QUERY --loop open --load $M_LOAD

        for ((l=$load_start; l<=$LOAD; l=$((l+$load_server_incrementer))));do
          export first_time=no

          # keep last log
          printf "\n"
          printf "\n"
          printf "\n"

          echo "********   STARTING EXP PRELIM STEPS   ************"
          printf "\n"

          echo "removing previous exp load script output ::: traffic_gen/traffic_gen.log"
          cd ~/projects/solrcloud;pssh -l dporte7 -h "${LOADHOSTS}_${LOAD}" "echo ''>traffic_gen/traffic_gen.log"
          printf "\n\n\n\n"
          echo " PARAMETERS TO runscript.sh:::: "
          echo "\$ ./tests_v1/scriptsThatRunLoadServers/runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $(($procs*$l*$app_threads)) --solrnum $SOLRNUM --query $QUERY --loop open --load $l"
          printf "\n\n"

          cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $(($procs*$l*$app_threads)) --solrnum $SOLRNUM --query $QUERY --loop open --load $l
          sleep 2

        done


        export load_server_incrementer=$load_server_incrementer
        for ((l=$load_server_incrementer; l<=$(($EXTRA_ITERS)); l=$((l+$load_server_incrementer))));do
          export first_time=no
          export second_pass=$l
          echo " SECOND PASS !!! $l"

          if [ $EXTRA_ITERS -eq 0 ]; then
            break
          fi

          # keep last log
          printf "\n"
          printf "\n"
          printf "\n"

          tmp=$(($l*35))
          pro=$(($procs*$LOAD*$app_threads))
          parallel_requests=$(($tmp+$pro))

          echo "********   STARTING EXP PRELIM STEPS   ************"
          printf "\n"

          echo "removing previous exp load script output ::: traffic_gen/traffic_gen.log"
          cd ~/projects/solrcloud;pssh -l dporte7 -h "${LOADHOSTS}_${LOAD}" "echo ''>traffic_gen/traffic_gen.log"
          printf "\n\n\n\n"
          echo " PARAMETERS TO runscript.sh:::: "
          echo "\$ ./tests_v1/scriptsThatRunLoadServers/runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $(($procs*$LOAD*$app_threads)) --solrnum $SOLRNUM --query $QUERY --loop open --load $LOAD"
          printf "\n\n"

          cd ~/projects/solrcloud/tests_v1/scriptsThatRunLoadServers; bash runtest.sh traffic_gen words.txt --user dporte7 -rf $RF -s $SHARD -t ${app_threads} -d 10 -p $parallel_requests --solrnum $SOLRNUM --query $QUERY --loop open --load $LOAD
          sleep 2
        done



        if [ "$DSTAT_SWITCH" = on ];then
          for n in $ALL_NODES;do
            ssh $USER@$n "pkill -f dstat" >/dev/null 2>&1 &
          done
          DSTAT_DIR="${PROJ_HOME}/rf_${RF}_s${SHARD}_solrnum${SOLRNUM}_query${QUERY}"
          mkdir $DSTAT_DIR
          for n in $ALL_NODES;do
            scp -r $USER@${n}:~/*dstat.csv $DSTAT_DIR
          done
          mv $DSTAT_DIR "/Users/dporter/projects/solrcloud/chart/exp_records/$CHARTNAME"
        fi




    # need to call stopsolr it here since it needs to stop this exp explicitly before running a new one
        stopSolr $SERVERNODE
        play post_data_$SERVERNODE.yml --tags aws_exp_reset --extra-vars "replicas=$RF shards=$SHARD clustersize=$SERVERNODE"

        # next RF
        archivePrev $CHARTNAME $SERVERNODE $QUERY $RF $SHARD

      done
      # next shard
    done
    # next servernode
  done
  # next query
  python3 /Users/dporter/projects/solrcloud/chart/chart_all_full.py $QUERY $CHARTNAME
  python3 /Users/dporter/projects/solrcloud/chart/chartit_error_bars.py $QUERY $CHARTNAME
  zip -r /Users/dporter/projects/solrcloud/chart/exp_html_out/_$CHARTNAME/exp_zip.zip /Users/dporter/projects/solrcloud/chart/exp_records/$CHARTNAME
done
