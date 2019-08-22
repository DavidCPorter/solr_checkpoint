#! /bin/bash

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

    echo 'Copying python scripts tol remote machine'
    scp -r $PY_SCRIPT $USER@node3:~/
    scp $TERMS $USER@node3:~/


    # parameters for py script running on node3
    PAR_0="--host 127.0.0.1 --port 9111 $THREADS $DURATION $CON $QUERY --output-dir ./"
    #PAR_N = foreground process terminates when all others terminate.
    PAR_N="--host 127.0.0.1 --port 9111 $THREADS $DURATION $CON $QUERY --output-dir ./"

    echo $PAR_0
    # run pyscript no hangup 'N' processes
    for i in $(seq $PROCESSES); do
    	nohup ssh $USER@node3 "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PAR_0 &"&
    done

    ssh $USER@node3 "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PAR_N"

    scp $USER@node3:~/traffic_gen/http_benchmark_${15}.csv profiling_data/

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
    DPARAMS='-t --cpu --mem --disk --io --net --int --sys --swap --tcp'

    PY_NAME=$(basename $PY_SCRIPT | cut -d '.' -f1)

    echo "q = $QUERY"
    echo "_$USER-"
    echo 'deleting node dstat remote files'
    nohup pssh -i -H "$USER@node0 $USER@node1 $USER@node2 $USER@node3" "rm ~/${15}_node*_dstat_$PY_NAME.csv"

    wait $!
  	echo 'Starting the dstat'
      nohup ssh $USER@node0 "dstat $DPARAMS --output ${15}_node0_dstat_$PY_NAME.csv &>/dev/null &"
      nohup ssh $USER@node1 "dstat $DPARAMS --output ${15}_node1_dstat_$PY_NAME.csv &>/dev/null &"
      nohup ssh $USER@node2 "dstat $DPARAMS --output ${15}_node2_dstat_$PY_NAME.csv &>/dev/null &"
      nohup ssh $USER@node3 "dstat $DPARAMS --output ${15}_node3_dstat_$PY_NAME.csv &>/dev/null &"

  	echo 'Starting the experiment'
  	 start_experiment $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $CON $SIZE $QUERY

    # start_experiment returns after requests


    echo 'Stopping dstat'
      nohup parallel-ssh -i -H "$USER@node0 $USER@node1 $USER@node2 $USER@node3" "ps aux | grep -i 'dstat*' | awk -F' ' '{print \$2}' | xargs kill -9"

    echo 'Copying the remote dstat data to local -> /profiling_data'
      for i in `seq 0 3`; do
          scp $USER@node$i:"./${15}_node${i}_dstat_$PY_NAME.csv" profiling_data/
      done



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

echo "$THREADS $PROCESSES $DURATION $CON $SIZE"

PY_SCRIPT="traffic_gen"
TERMS="words.txt"

#PARAMETERS=$3

echo 'Starting the experiment'
# start_experiment $USER $PY_SCRIPT

profile_experiment_dstat $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $CON $SIZE $QUERY

#start_experiment $USER $PY_SCRIPT "\"$PARAMETERS\""

exit
