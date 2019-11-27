#!/bin/bash

PROJECT_HOME='/Users/dporter/projects/solrcloud'
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
  INSTANCES="${21}"

  node16="128.110.153.163"
  node17="128.110.153.154"
  node18="128.110.153.167"
  node19="128.110.153.189"
  node20="128.110.153.188"
  node21="128.110.153.217"
  node22="128.110.153.176"
  node23="128.110.153.172"


  # these correlate the order in the ssh_files
  LOAD_NODES=( $node16 $node17 $node18 $node19 $node20 $node21 $node22 $node23 )
  # loadsize = num of load servers
  LOADSIZE=8

  echo "LOAD_NODES = $LOAD_NODES"
  echo 'Copying python scripts to remote machine'
  pscp -l $USER -r -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_8 $PY_SCRIPT /users/dporte7
  pscp -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_8 $TERMS /users/dporte7


  SINGLE_PAR="$THREADS $DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM --instances $INSTANCES --connections 1 --output-dir ./ --host 10.10.1.1"

  echo "removing previous output from remote and local host"
  pssh -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_8 --user $USER "rm ~/traffic_gen/http_benchmark_*"
  rm $PROJECT_HOME/tests_v1/profiling_data/proc_results/http_benchmark_*
  MINUS1="$(($PROCESSES - 1))"


########## EXPERIMENT LOOPS #################

  echo "running on single solr server"
  echo "#!/bin/bash" > $RSCRIPTS/remotescript.sh
  echo "#!/bin/bash" > $RSCRIPTS/remotescript_foreground.sh
  echo "# this file is used to run processes remotely since cloudlab blacklists aggressive ssh" >> $RSCRIPTS/remotescript.sh

  # this will allocate the processes connections accross the ports open for each solr instance on server 1
  for i in `seq $MINUS1`; do
    if [ $INSTANCES = "1" ]; then
      echo "ONLY SINGLE INSTANCE"
      break
    fi

    echo "$i"
    temp=$i
    echo "python3 traffic_gen.py $SINGLE_PAR --port 99$temp$temp >/dev/null 2>&1 &" >> $RSCRIPTS/remotescript.sh
    echo "python3 traffic_gen.py $SINGLE_PAR --port 99$temp$temp >/dev/null 2>&1 &" >> $RSCRIPTS/remotescript_foreground.sh
  done

  echo "python3 traffic_gen.py $SINGLE_PAR --port 8983 >/dev/null 2>&1 &" >> $RSCRIPTS/remotescript.sh
  # see if changing this will affect solrj
  echo "python3 traffic_gen.py $SINGLE_PAR --port 8983" >> $RSCRIPTS/remotescript_foreground.sh
  # run remotescripts on all background nodes
  pscp -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_7 $RSCRIPTS/remotescript.sh /users/$USER/traffic_gen
  pscp -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_single $RSCRIPTS/remotescript_foreground.sh /users/$USER/traffic_gen


  #### RUNNING EXPERIMENTS #####
  echo "RUNNING THIS REMOTE SHELL SCRIPT ON LOAD NODES"
  cat $RSCRIPTS/remotescript_foreground.sh
  # BACKGROUND LOAD GEN NODES
  nohup pssh -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_7 "cd $(basename $PY_SCRIPT); bash remotescript.sh"&
  # FOREGROUND LOAD GEN NODE
  nohup ssh $USER@$node20 "cd $(basename $PY_SCRIPT); bash remotescript_foreground.sh"
  wait $!
  echo "finished EXP"
  #### FINISHED #####


  echo "copying results... "

  # wait for slow processes to complete (prolly not effective)
  sleep 5
  for i in "${LOAD_NODES[@]}"; do
      scp $USER@$i:~/traffic_gen/http_benchmark_${15}* profiling_data/proc_results &
  done
  wait $!
  sleep 5
  python3 $PROJECT_HOME/tests_v1/traffic_gen/readresults.py $PROCESSES $THREADS $DURATION $REPLICAS $QUERY $LOOP $SHARDS $SOLRNUM $LOADSIZE $INSTANCES
  DATE=$(date '+%Y-%m-%d_%H:%M:%S')
  # for reference
  zip -r ${DATE}_query${15}_rf${11}_s${13}_clustersize${19}_threads${5}_proc${7}.zip profiling_data/proc_results
  printf "\n\n DONE with $(($THREADS*$LOADSIZE)) outstanding requests in \n python3 traffic_gen.py $SINGLE_PAR --port $(($PROCESSES % $INSTANCES)) \n\n\n\n\n "

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
    INSTANCES="${20} ${21}"


    DPARAMS='-t --cpu --mem --disk --io --net --int --sys --swap --tcp'

    PY_NAME=$(basename $PY_SCRIPT | cut -d '.' -f1)

    # echo 'deleting node dstat remote files'
    DATE=$(date '+%Y-%m-%d_%H:%M:%S')
    # nohup pssh -i -l $USER -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "rm ~/${DATE}_rf${11}_s${13}_clustersize${19}_threads${5}_proc${7}_dstat_$PY_NAME.csv" &
    # sleep 1
  	# echo 'Starting the dstat'
    # nohup pssh -i -l $USER -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "dstat $DPARAMS --output ${15}_node_dstat_$PY_NAME.csv >/dev/null 2>&1" &
    # nohup pssh -i -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file "cd solrclientserver;java -cp target/solrclientserver-1.0-SNAPSHOT.jar com.dporte7.solrclientserver.DistributedWebServer" &
  	echo 'Starting the experiment'
  	 start_experiment $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM $INSTANCES

    # start_experiment returns after requests


    # echo 'Stopping dstat'
    #   nohup pssh -l $USER -i -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "ps aux | grep -i 'dstat*' | awk -F' ' '{print \$2}' | xargs kill -9 >/dev/null 2>&1" &

    echo 'Copying the remote dstat data to local -> /profiling_data'
    echo 'TO DO'

    # pscp $USER@node$i:"~/${15}_node${i}_dstat_$PY_NAME.csv" profiling_data/

    echo 'Done'

  }


if [ "$#" -lt 3 ]; then
    echo "Usage: runtest_single.sh <python scripts dir> <search term list> [ -u | --user ] [ -p | --processes ] [ -t | ---threads ] [ -d | --duration ] [--instances] [--solrnum]"
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
    --instances)
      INSTANCES="--instances $2"
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

profile_experiment_dstat $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM $INSTANCES

#start_experiment $USER $PY_SCRIPT "\"$PARAMETERS\""

exit