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
    LOOP="${16} ${17}"

    echo 'Copying python scripts to remote machine'
    scp -r $PY_SCRIPT $USER@node3:~/
    scp $TERMS $USER@node3:~/


    # parameters for py script running on node3
    PAR_0="--host 127.0.0.1 --port 9111 $THREADS $DURATION $CON $QUERY $LOOP --output-dir ./"
    PAR_1="--host 127.0.0.1 --port 9222 $THREADS $DURATION $CON $QUERY $LOOP --output-dir ./"
    PAR_2="--host 127.0.0.1 --port 9333 $THREADS $DURATION $CON $QUERY $LOOP --output-dir ./"
    #PAR_N == foreground process terminates when all others terminate.
    PAR_N="--host 127.0.0.1 --port 9333 $THREADS $DURATION $CON $QUERY $LOOP --output-dir ./"


    # run pyscript no hangup 'N' processes
    if [ $PROCESSES = '1' ]; then
      echo "starting"
      ssh $USER@node3 "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PAR_N"
      wait $!
      echo "finished"
      scp $USER@node3:~/traffic_gen/http_benchmark_${15}.csv profiling_data/

    else

      MINUS1="$((PROCESSES - 1))"
      # PARAMS=""
      if [ ${15} = 'local' ]; then
        for i in $(seq $MINUS1); do
          # PARMS will not be used in this case
          PARAMS=$(eval 'echo $PAR_'"$(($i % 3))")
        	python3 ~/projects/solrcloud/tests_v1/traffic_gen/traffic_gen.py $PARAMS>/dev/null 2>&1 &
        done
        echo "starting"
        python3 ~/projects/solrcloud/tests_v1/traffic_gen/traffic_gen.py $PARAMS
        echo "finished"


      else
        for i in $(seq $MINUS1); do
          echo "$i"
          PARAMS=$(eval 'echo $PAR_'"$(($i % 3))")
          echo "$PARAMS"
        	nohup ssh $USER@node3 "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PARAMS" &
        done
        PARAMS=$(eval 'echo $PAR_'"$(($PROCESSES % 3))")
        echo "starting $PARAMS"
        nohup ssh $USER@node3 "cd $(basename $PY_SCRIPT); python3 traffic_gen.py $PARAMS"
        wait $!
        echo "finished"
      fi


    # scp $USER@node3:~/traffic_gen/first/http_benchmark_${15}.csv profiling_data/first
    # scp $USER@node3:~/traffic_gen/second/http_benchmark_${15}.csv profiling_data/second
    # scp $USER@node3:~/traffic_gen/third/http_benchmark_${15}.csv profiling_data/third
      rm ~/projects/solrcloud/tests_v1/profiling_data/http_benchmark_${15}*
      wait $!
      sleep 2
      scp $USER@node3:~/traffic_gen/http_benchmark_${15}* profiling_data/
      ssh $USER@node3 "rm ~/traffic_gen/http_benchmark_${15}*"
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
    nohup pssh -i -H "$USER@node0 $USER@node1 $USER@node2 $USER@node3" "rm ~/${15}_node*_dstat_$PY_NAME.csv" >/dev/null 2>&1 &
    sleep 1
  	echo 'Starting the dstat'
      nohup ssh $USER@node0 "dstat $DPARAMS --output ${15}_node0_dstat_$PY_NAME.csv &>/dev/null &" >/dev/null 2>&1 &
      nohup ssh $USER@node1 "dstat $DPARAMS --output ${15}_node1_dstat_$PY_NAME.csv &>/dev/null &" >/dev/null 2>&1 &
      nohup ssh $USER@node2 "dstat $DPARAMS --output ${15}_node2_dstat_$PY_NAME.csv &>/dev/null &" >/dev/null 2>&1 &
      nohup ssh $USER@node3 "dstat $DPARAMS --output ${15}_node3_dstat_$PY_NAME.csv &>/dev/null &" >/dev/null 2>&1 &

  	echo 'Starting the experiment'
  	 start_experiment $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $CON $SIZE $QUERY $LOOP

    # start_experiment returns after requests


    echo 'Stopping dstat'
      nohup pssh -i -H "$USER@node0 $USER@node1 $USER@node2 $USER@node3" "ps aux | grep -i 'dstat*' | awk -F' ' '{print \$2}' | xargs kill -9" >/dev/null 2>&1 &

    echo 'Copying the remote dstat data to local -> /profiling_data'
      for i in `seq 0 3`; do
          scp $USER@node$i:"~/${15}_node${i}_dstat_$PY_NAME.csv" profiling_data/
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
