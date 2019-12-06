#! /bin/bash


RSCRIPTS=$PROJECT_HOME/tests_v1/remotescripts



function start_experiment() {

  if [ "$#" -lt 3 ]; then
      echo "Usage: start_experiment <username> <python scripts dir> <term list textfile>"
  	exit
  fi
  USER=$1
	PY_SCRIPT=$2
  TERMS=$3
  THREADS="$4 $5"
  PROCESSES="$7"
  DURATION="$8 $9"
  REPLICAS="${10} ${11}"
  SHARDS="${12} ${13}"
  QUERY="${14} ${15}"
  LOOP="${16} ${17}"
  SOLRNUM="${18} ${19}"
  LOAD="${21}"
  INSTANCES="0"
  SOLR_SIZE=${19}
  # these correlate the order in the ssh_files

  # loadsize = num of load servers
  LOADSIZE=$LOAD

  echo "LOAD"
  tmp=$(setLoadArray $LOADSIZE)
  # LOAD_NODES is the array of IPs for the specified loadsize
  LOAD_NODES=($tmp)

  # echo "$LOAD_NODES"
  # echo "LOAD_NODES = ${LOAD_NODES[1]}"
  echo 'Copying python scripts to remote machine'
  pscp -l $USER -r -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_8 $PY_SCRIPT /users/dporte7
  pscp -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_8 $TERMS /users/dporte7

  # each process in the python script will make #THREAD num of REPLICASnections to a SINGLE solr instance "--host" (for --query direct)
  # parameters for py script running on nodes 32, 33, 34, 35
  # hosts here will either be this local for solrj since solj is running on same node, or a subnet address
  # different ports reflect the number of solrj processes on each node running solrj
  #  otherwise ports will be changed to 8983 since solrcloud httpserver runs there on the network
  PAR_0="$DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM --connections 1 --output-dir ./ --port 9111" #host appended below
  PAR_1="$DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM --connections 1 --output-dir ./ --port 9222" #host appended below
  PAR_2="$DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM --connections 1 --output-dir ./ --port 9333" #host appended below
  PAR_3="$DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM --connections 1 --output-dir ./ --port 9444" #host appended below

  echo "removing previous output from remote and local host"
  pssh -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_8 --user $USER "rm ~/traffic_gen/http_benchmark_*"
  rm $PROJECT_HOME/tests_v1/profiling_data/proc_results/*
# THIS MIGHT HAVE BEEN THE PROBLEM

########## EXPERIMENTS #################


  echo "*** running remote experiment ****"
  for i in "${LOAD_NODES[@]}";do
    mkdir $RSCRIPTS/${i}
    touch $RSCRIPTS/${i}/remotescript.sh
  done


  for i in "${LOAD_NODES[@]}";do
    echo "#!/bin/bash" > $RSCRIPTS/${i}/remotescript.sh
  done

  # iterate over the number of python web processes you want communicating to the cluster and assign each process to an available load node
#  16 is the number of cores on each load machine
  LOAD_ITER_MAX=$(($LOADSIZE-1))

  for ((l=0; l<$LOAD_ITER_MAX; l++)); do
    LUCKY_LOAD=${LOAD_NODES[$l]}
    if [ $l -gt 0 ];then
      THREADS="--threads 2"
    fi

    for ((i=1; i<=32; i++)); do
      # if more than 1 node, then the nodes subsequent to the first always have the max three threads for optimal parallelism
      PARAMS=$(eval 'echo $PAR_'"$(($i % 4))")
    	echo "python3 traffic_gen.py $THREADS $PARAMS --host 10.10.1.$(($(($i % $SOLR_SIZE))+1)) >/dev/null 2>&1 &" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh
    done
  done

  # foreground is so the experiment will wait for these procs to finish.
  LUCKY_LOAD=${LOAD_NODES[$LOAD_ITER_MAX]}
  if [ $LOAD_ITER_MAX -gt 0 ];then
    THREADS="--threads 2"
  fi
  for ((i=1; i<=31; i++)); do
    # if more than 1 node, then the nodes subsequent to the first always have the max three threads for optimal parallelism
    PARAMS=$(eval 'echo $PAR_'"$(($i % 4))")
    echo "python3 traffic_gen.py $THREADS $PARAMS --host 10.10.1.$(($(($i % $SOLR_SIZE))+1)) >/dev/null 2>&1 &" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh
  done
  echo "python3 traffic_gen.py $THREADS $PARAMS --host 10.10.1.$(($((16 % $SOLR_SIZE))+1)) >/dev/null 2>&1" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh


# copy to respective load nodes
  for noder in "${LOAD_NODES[@]}";do
    scp ${RSCRIPTS}/${noder}/remotescript.sh $USER@${noder}:/users/${USER}/traffic_gen
  done

#### RUNNING EXPERIMENTS #####
  echo "RUNNING THIS REMOTE SHELL SCRIPT ON LOAD NODES"
  for i in "${LOAD_NODES[@]}";do
    echo "${i}::"
    cat $RSCRIPTS/${i}/remotescript.sh
  done
  echo "nohup output to loadoutput.out"

  # BACKGROUND LOAD GEN NODES
#  nohup pssh -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_$(($LOADSIZE-1)) "cd $(basename $PY_SCRIPT); bash remotescript_net.sh"&
  nohup pssh -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_$LOADSIZE "cd $(basename $PY_SCRIPT); bash remotescript.sh" > loadoutput.out
  wait $!
  echo "finished EXP"
#### FINISHED #####


  echo "copying results... "

  # wait for slow processes to complete (prolly not effective)
  sleep 2
  for i in "${LOAD_NODES[@]}"; do
      echo "$i"
#        scp $USER@$i:~/traffic_gen/iftop_log* $PROJECT_HOME/tests_v1/profiling_data/network_monitoring/${THREADS}_${SOLRNUM} &
#        scp $USER@$i:~/traffic_gen/iftop_log* $PROJECT_HOME/tests_v1/profiling_data/network_monitoring &
#
      scp $USER@$i:~/traffic_gen/http_benchmark_${15}* $PROJECT_HOME/tests_v1/profiling_data/proc_results &
  done

  wait $!
  sleep 1
  printf "\n\n\n"
  echo "$PROJECT_HOME/tests_v1/traffic_gen/readresults.py $PROCESSES $THREADS $DURATION $REPLICAS $QUERY $LOOP $SHARDS $SOLRNUM $LOADSIZE $INSTANCES"
  python3 $PROJECT_HOME/tests_v1/traffic_gen/readresults.py $PROCESSES $THREADS $DURATION $REPLICAS $QUERY $LOOP $SHARDS $SOLRNUM $LOADSIZE $INSTANCES
  wait $!
  DATE=$(date '+%Y-%m-%d_%H:%M:%S')
  touch $PROJECT_HOME/tests_v1/profiling_data/proc_results/javaServer.log
  for i in "${LOAD_NODES[@]}";do
    echo "${i}::" >> $PROJECT_HOME/tests_v1/profiling_data/proc_results/javaServer.log
    ssh dporte7@$i tail -n 10 /users/dporte7/solrclientserver/javaServer.log >> $PROJECT_HOME/tests_v1/profiling_data/proc_results/javaServer.log
  done
  pssh -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_$LOADSIZE "echo ''> /users/dporte7/solrclientserver/javaServer.log"
  # for reference fcts
  zip -r $PROJECT_HOME/tests_v1/${DATE}_query${15}_rf${11}_s${13}_clustersize${19}_threads${5}_proc${7}.zip $PROJECT_HOME/tests_v1/profiling_data/proc_results

  printf "\n\n\n "
  echo "DONE with $THREADS X $LOADSIZE outstanding requests in"

}

function profile_experiment_dstat() {

    if [ "$#" -lt 3 ]; then
        echo "Usage: profile_experiment_dstat <username> <python scripts dir> <search term list>"
    	exit
    fi
    USER=$1
  	PY_SCRIPT=$2
    TERMS=$3
    THREADS="$4 $5"
    PROCESSES="$6 $7"
    DURATION="$8 $9"
    REPLICAS="${10} ${11}"
    SHARDS="${12} ${13}"
    QUERY="${14} ${15}"
	  #PARAMETERS=$3

    LOOP="${16} ${17}"
    SOLRNUM="${18} ${19}"
    LOAD="${20} ${21}"

    DPARAMS='-t --cpu --mem --disk --io --net --int --sys --swap --tcp'

    PY_NAME=$(basename $PY_SCRIPT | cut -d '.' -f1)

    # echo 'deleting node dstat remote files'
    # DATE=$(date '+%Y-%m-%d_%H:%M:%S')
    # nohup pssh -i -l $USER -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "rm ~/${DATE}_rf${11}_s${13}_clustersize${19}_threads${5}_proc${7}_dstat_$PY_NAME.csv" &
    # sleep 1
  	# echo 'Starting the dstat'
    # nohup pssh -i -l $USER -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "dstat $DPARAMS --output ${15}_node_dstat_$PY_NAME.csv >/dev/null 2>&1" &
    # nohup pssh -i -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file "cd solrclientserver;java -cp target/solrclientserver-1.0-SNAPSHOT.jar com.dporte7.solrclientserver.DistributedWebServer" &
  	echo 'Starting the experiment'
  	 start_experiment $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM $LOAD

    # start_experiment returns after requests


    # echo 'Stopping dstat'
    #   nohup pssh -l $USER -i -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "ps aux | grep -i 'dstat*' | awk -F' ' '{print \$2}' | xargs kill -9 >/dev/null 2>&1" &

    # echo 'Copying the remote dstat data to local -> /profiling_data'
    # echo 'TO DO'
    #
    # # pscp $USER@node$i:"~/${15}_node${i}_dstat_$PY_NAME.csv" profiling_data/
    #
    # echo 'Done'

  }


if [ "$#" -lt 3 ]; then
    echo "Usage: runtest.sh <python scripts dir> <search term list> [ -u | --user ] [ -p | --processes ] [ -t | ---threads ] [ -d | --duration ] [ -c | --REPLICASnections ]"
	exit
fi
# initialize to ensure absent params don't mess the local var order up.
PARAMS=""
USER="x"
PY_SCRIPT="x"
TERMS="x"
THREADS="x x"
PROCESSES="x x"
DURATION="x x"
REPLICAS="x x" 
SHARDS="x x"
QUERY="x x"
LOOP="x x"
SOLRNUM="x x"
INSTANCES="x x"


while (( "$#" )); do
  case "$1" in
    -t|--threads)
      THREADS="--threads $2"
      shift 2
      ;;
    -p|--processes)
      PROCESSES="--processes $2"
      shift 2
      ;;
    -d|--duration)
      DURATION="--duration $2"
      shift 2
      ;;
    -rf|--replicas)
      REPLICAS="--replicas $2"
      REPLICA_PARAM=$2
      shift 2
      ;;
    -s|--shards)
      SHARDS="--shards $2"
      SHARD_PARAM=$2
      shift 2
      ;;
    -u|--user)
      USER="$2"
      shift 2
      ;;
    --query)
      QUERY="--query $2"
      shift 2
      ;;

    --loop)
      LOOP="--loop $2"
      shift 2
      ;;

    --solrnum)
      SOLRNUM="--solrnum $2"
      SOLRNUM_PARAM=$2
      shift 2
      ;;

    --load)
      LOAD="--load $2"
      shift 2
      ;;

    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done


PY_SCRIPT="traffic_gen"
TERMS="words.txt"

#PARAMETERS=$3
# this should be done in the exp loop script after loop finishes, not for each exp.
  # echo "checking if cores exist for reviews_ $SHARDS $REPLICAS"
  # cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --tags exp_mode --extra-vars "replicas=${REPLICA_PARAM} shards=${SHARD_PARAM} clustersize=${SOLRNUM_PARAM}"
  # wait $!

cd ~/projects/solrcloud/tests_v1;
echo 'Starting the experiment'
# start_experiment $USER $PY_SCRIPT

profile_experiment_dstat $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM $LOAD

#start_experiment $USER $PY_SCRIPT "\"$PARAMETERS\""

exit
