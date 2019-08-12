#! /bin/bash

function start_experiment() {

    if [ "$#" -ne 2 ]; then
        echo "Usage: start_experiment <username> <python script>"
    	exit
    fi

  	USER=$1
  	PY_SCRIPT=$2


    echo 'Coping python script on remote machine'
    scp $PY_SCRIPT $USER@node3:~/

    # parameters for py script running on node3
    PAR_0="--host 127.0.0.1 --port 9111 --threads 5 --duration 30 --connections 3 --output-dir ./"
    PAR_1="--host 127.0.0.1 --port 9111 --threads 5 --duration 30 --connections 3 --output-dir ./"
    #PAR_N = foreground process terminates when all others terminate.
    PAR_N="--host 127.0.0.1 --port 9111 --threads 5 --duration 30 --connections 3 --output-dir ./"

    # run pyscript no hangup 'N' processes
    for i in $(seq 6); do
    	nohup ssh $USER@node3 "python3 $(basename $PY_SCRIPT) $PAR_0 &"&
      nohup ssh $USER@node3 "python3 $(basename $PY_SCRIPT) $PAR_1 &"&
    done

    ssh $USER@node3 "python3 $(basename $PY_SCRIPT) $PAR_N"

    scp $USER@node3:~/http_benchmark.csv profiling_data/

}

function profile_experiment_dstat() {

    if [ "$#" -ne 2 ]; then
        echo "Usage: profile_experiment_dstat <username> <python script>"
    	exit
    fi

  	USER=$1
  	PY_SCRIPT=$2
	  #PARAMETERS=$3

    PY_NAME=$(basename $PY_SCRIPT | cut -d '.' -f1)

    nohup parallel-ssh -i -H "$USER@node0 $USER@node1 $USER@node2 $USER@node3" "rm ~/node*_dstat_$PY_NAME.csv"

  	echo 'Starting the dstat'
      nohup ssh $USER@node0 "dstat --output node0_dstat_$PY_NAME.csv &>/dev/null &"
      nohup ssh $USER@node1 "dstat --output node1_dstat_$PY_NAME.csv &>/dev/null &"
      nohup ssh $USER@node2 "dstat --output node2_dstat_$PY_NAME.csv &>/dev/null &"
      nohup ssh $USER@node3 "dstat --output node3_dstat_$PY_NAME.csv &>/dev/null &"

  	echo 'Starting the experiment'
  	 start_experiment $USER $PY_SCRIPT

    # start_experiment returns after requests


    echo 'Stopping dstat'
      nohup parallel-ssh -i -H "$USER@node0 $USER@node1 $USER@node2 $USER@node3" "ps aux | grep -i 'dstat*' | awk -F' ' '{print \$2}' | xargs kill -9"

    echo 'Copying the remote dstat data to local -> /profiling_data'
      for i in `seq 0 3`; do
          scp $USER@node$i:"./node${i}_dstat_$PY_NAME.csv" profiling_data/
      done

    echo 'Done'

 }


if [ "$#" -ne 2 ]; then
    echo "Usage: utils.sh <username> <python script>"
	exit
fi

USER=$1
PY_SCRIPT=$2
#PARAMETERS=$3

echo 'Starting the experiment'
# start_experiment $USER $PY_SCRIPT

profile_experiment_dstat $USER $PY_SCRIPT

#start_experiment $USER $PY_SCRIPT "\"$PARAMETERS\""

exit
