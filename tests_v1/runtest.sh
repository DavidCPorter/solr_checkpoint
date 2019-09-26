#! /bin/bash

PROJECT_HOME='/Users/dporter/projects/solrcloud'

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
    CON="${10} ${11}"
    SIZE="${12} ${13}"
    QUERY="${14} ${15}"
    LOOP="${16} ${17}"
    LOAD_NODES=("128.110.153.246" "128.110.154.30" "128.110.154.35" "128.110.154.16")
    echo $PROJECT_HOME
    echo 'Copying python scripts to remote machine'
    pscp -l $USER -r -h $PROJECT_HOME/pssh_traffic_node_file $PY_SCRIPT /users/dporte7
    pscp -l $USER -h $PROJECT_HOME/pssh_traffic_node_file $TERMS /users/dporte7

    # each process in the python script will make #THREAD num of connections to a SINGLE solr instance "--host" (for --query direct)
    # parameters for py script running on nodes 32, 33, 34, 35
    # hosts here will either be this local for solrj since solj is running on same node, or a subnet address
    # different ports reflect the number of solrj processes on each node running solrj
    #  otherwise ports will be changed to 8983 since solrcloud httpserver runs there on the network
    PAR_0="$THREADS $DURATION $CON $QUERY $LOOP --output-dir ./ --port 9111" #host appended below
    PAR_1="$THREADS $DURATION $CON $QUERY $LOOP --output-dir ./ --port 9222" #host appended below
    PAR_2="$THREADS $DURATION $CON $QUERY $LOOP --output-dir ./ --port 9333" #host appended below
    PAR_3="$THREADS $DURATION $CON $QUERY $LOOP --output-dir ./ --port 9444" #host appended below

    echo "removing previous output from remote and local host"
    pssh -h $PROJECT_HOME/pssh_traffic_node_file --user $USER "rm ~/traffic_gen/http_benchmark_*"
    rm $PROJECT_HOME/tests_v1/profiling_data/proc_results/http_benchmark_${15}*


########## EXPERIMENT LOOPS #################


# SINGLE PROCESS
    if [ $PROCESSES = '1' ]; then
      echo "starting a single process experiment"
      pssh -h $PROJECT_HOME/pssh_traffic_node_file_single --user $USER "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PAR_0"
      wait $!
      echo "finished"
      # do something better later cuz pscp is terrible
      for i in "${LOAD_NODES[@]}"; do
          scp $USER@$i:"~/${15}_node${i}_dstat_$PY_NAME.csv" profiling_data/
      done


# LOCAL EXPERIMENT
# dont use this anymore
      # if [ ${15} = 'local' ]; then
      #   echo "***running local experiment****"
      #   for i in $(seq $MINUS1); do
      #     # PARMS will not be used in this case
      #     PARAMS=$(eval 'echo $PAR_'"$(($i % 4))")
      #   	python3 $PROJECT_HOME/tests_v1/traffic_gen/traffic_gen.py $PARAMS --host >/dev/null 2>&1 &
      #   done
      #   echo "starting"
      #   python3 $PROJECT_HOME/tests_v1/traffic_gen/traffic_gen.py $PARAMS  --host
      #   echo "finished"

  # REMOTE EXPERIMENT WITH X PROCESSES
  # have to DIVIDE the num or processes over 4 load nodes each connecting to one of 32 servers for direct 32 exp
    else

      MINUS1="$((PROCESSES - 1))"

      echo "*** running remote experiment ****"
      # clear script to run python processes
      echo "#!/bin/bash" > ./remotescript.sh
      echo "# this file is used to run processes remotely since cloudlab blacklists aggressive ssh" > ./remotescript.sh

      # append number of $PROCESSES-1 ($MINUS1) to remotescript
      for i in $(seq $MINUS1); do
        echo "$i"
        PARAMS=$(eval 'echo $PAR_'"$(($i % 4))")
        echo "$PARAMS"
      	echo "python3 traffic_gen.py $PARAMS --host 10.10.1.$i> /dev/null 2>&1 &" >> ./remotescript.sh
      done
      # create params for one process in foreground
      PARAMS=$(eval 'echo $PAR_'"$(($PROCESSES % 4))")
      echo "starting $PARAMS --host 10.10.1.$PROCESSES"
      # run remotescript
      pscp -l $USER -h $PROJECT_HOME/pssh_traffic_node_file_3 ./remotescript.sh /users/$USER/traffic_gen
      nohup pssh -l $USER -h $PROJECT_HOME/pssh_traffic_node_file_3 "cd $(basename $PY_SCRIPT); bash remotescript.sh"&
      # run foreground process
      nohup ssh $USER@128.110.153.246 "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PARAMS --host 10.10.1.$PROCESSES"
      echo "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PARAMS --host 10.10.1.$PROCESSES"
      wait $!
      echo "finished"

# wait for slow processes to complete
    sleep 20
    for i in "${LOAD_NODES[@]}"; do
        scp $USER@$i:~/traffic_gen/http_benchmark_${15}* profiling_data/proc_results &
    done
    wait $!
    sleep 5
    python3 $PROJECT_HOME/tests_v1/traffic_gen/readresults.py $PROCESSES $THREADS $DURATION $CON $QUERY $LOOP
  fi
}

function profile_experiment_dstat() {

    if [ "$#" -lt 3 ]; then
        echo "Usage: profile_experiment_dstat <username> <python scripts dir> <search term list>"
    	exit
    fi

    # params = $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $CON $SIZE

    USER=$1
  	PY_SCRIPT=$2
    TERMS=$3
    THREADS="$4 $5"
    PROCESSES="$6 $7"
    DURATION="$8 $9"
    CON="${10} ${11}"
    SIZE="${12} ${13}"
    QUERY="${14} ${15}"
	  #PARAMETERS=$3

    LOOP="${16} ${17}"
    DPARAMS='-t --cpu --mem --disk --io --net --int --sys --swap --tcp'

    PY_NAME=$(basename $PY_SCRIPT | cut -d '.' -f1)

    echo "q = $QUERY"
    echo "_$USER-"
    echo 'deleting node dstat remote files'
    nohup pssh -i -l $USER -h $PROJECT_HOME/pssh_solr_node_file "rm ~/${15}_node*_dstat_$PY_NAME.csv" >/dev/null 2>&1 &
    sleep 1
  	echo 'Starting the dstat'
      nohup pssh -i -l $USER -h $PROJECT_HOME/pssh_solr_node_file "dstat $DPARAMS --output ${15}_node0_dstat_$PY_NAME.csv &>/dev/null &" >/dev/null 2>&1 &

  	echo 'Starting the experiment'
  	 start_experiment $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $CON $SIZE $QUERY $LOOP

    # start_experiment returns after requests


    echo 'Stopping dstat'
      nohup pssh -l $USER -i -h $PROJECT_HOME/pssh_solr_node_file "ps aux | grep -i 'dstat*' | awk -F' ' '{print \$2}' | xargs kill -9 >/dev/null 2>&1" &

    echo 'Copying the remote dstat data to local -> /profiling_data'
    echo 'TO DO'

    # pscp $USER@node$i:"~/${15}_node${i}_dstat_$PY_NAME.csv" profiling_data/

    echo 'Done'

 }


if [ "$#" -lt 3 ]; then
    echo "Usage: runtest.sh <python scripts dir> <search term list> [ -u | --user ] [ -p | --processes ] [ -t | ---threads ] [ -d | --duration ] [ -c | --connections ]"
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
CON="x x"
SIZE="x x"
QUERY="x x"
LOOP="x x"

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
    -c|--connections)
      CON="--connections $2"
      shift 2
      ;;
    -s|--size)
      SIZE="--size $2"
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

echo 'Starting the experiment'
# start_experiment $USER $PY_SCRIPT

profile_experiment_dstat $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $CON $SIZE $QUERY $LOOP

#start_experiment $USER $PY_SCRIPT "\"$PARAMETERS\""

exit
