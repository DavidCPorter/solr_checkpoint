#! /bin/bash

RSCRIPTS=$PROJECT_HOME/tests_v1/remotescripts



# source /Users/dporter/projects/solrcloud/utils/utils.sh
# source /Users/dporter/projects/solrcloud/utils/exp_helpers.sh
# source /Users/dporter/projects/solrcloud/utils/exp_scale_loop_params.sh

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
  LOAD=${21}
  INSTANCES="${22} ${23}"
  SOLR_SIZE=${19}
  # loadsize = num of load servers
  LOADSIZE=$LOAD
  # proper array for this var
  LOAD_NODES=($(setLoadArray $LOADSIZE))
  ALL_LOAD_NODES=($(setLoadArray $M_LOAD))
  SINGLE_PAR=""
  PAR=""
  PARAMS=""



  printf "\n\n\n"
  echo "removing previous output from remote sources and local host copies"
  pssh -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file --user $USER "rm ~/traffic_gen/http_benchmark_*"
  rm $PROJECT_HOME/tests_v1/profiling_data/proc_results/*


  # LOAD_NODES is the array of IPs for the specified loadsize
  echo "THESE ARE THE LOAD NODES FOR THIS ITERATION OF EXP::"
  for i in "${LOAD_NODES[@]}";do
    echo $i
  done

  INSTANCES_BOOL=false

  if [ $SOLR_SIZE -eq "1" ];then
    INSTANCES_BOOL=true
  fi

  STANDALONE=false
  if [ $SOLR_SIZE -eq "0" ];then
    STANDALONE=true
    SOLR_SIZE=1
  fi





  # each process in the python script will make #THREAD num of REPLICASnections to a SINGLE solr instance "--host" (for --query direct)
  # parameters for py script running on nodes 32, 33, 34, 35
  # hosts here will either be this local for solrj since solj is running on same node, or a subnet address
  # different ports reflect the number of solrj processes on each node running solrj
  #  otherwise ports will be changed to 8983 since solrcloud httpserver runs there on the network

  # if wee have instances > 0 then we are in single node cluster mode
  if [ "$INSTANCES_BOOL" = true ];then
    # need to add port (instance) later
    SINGLE_PAR="$DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM $INSTANCES --connections 1 --output-dir ./"
  else
    PAR="$DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM --connections 1 --output-dir ./"
  fi





########## EXPERIMENTS #################
  # printf "\n"
  # echo "making dirs for copying remote scripts"
  # for i in "${LOAD_NODES[@]}";do
  #   mkdir $RSCRIPTS/${i}
  #   touch $RSCRIPTS/${i}/remotescript.sh
  # done

  if [ "$first_time" = yes ];then

    for i in "${ALL_LOAD_NODES[@]}";do
      echo "#!/bin/bash" > $RSCRIPTS/${i}/remotescript.sh
    done


    # the following is a loop
    #  for each load server, for each core on the load server, run this python process to one of the round robin solr servers
    #  this remains the same for both distributed cloud and singlenode except that single node passes instance param and does not RR through solr servers ~ just one 10.10.1.1.

  # single_instance_port_arr =  so we can load balance accross local cores
    single_instance_port_arr=( "8983" "9911" "9922" "9933" )

  ####### THIS IS FOR BACKGROUND NODES

    for ((l=0; l<$(($M_LOAD)); l++)); do
      LUCKY_LOAD=${ALL_LOAD_NODES[$l]}
      # always 2 threads now, not incrementing by one anymore
      # if [ $l -gt 0 ];then
      #   THREADS="--threads 2"
      # fi
  # 16 logical cores on each load server
      for ((i=1; i<=$(($procs)); i++)); do
        # if more than 1 node, then the nodes subsequent to the first always have the max three threads for optimal parallelism
        node_subnet_suffix=$(($(($i % $SOLR_SIZE))+1))
        # this port suffix thing is really just for solrj requests since solrj has multiple ports to serve requests
        port_num_suffix=$((($i % 4)+1))
        if [ "$SOLRJ_PORT_OVERRIDE" = true ];then
          port_num_suffix=4
        fi

        if [ "$INSTANCES_BOOL" = true ];then
          PARAMS="$SINGLE_PAR  --host 10.10.1.$node_subnet_suffix --port ${single_instance_port_arr[$(($i % 4))]}"
        else
          PARAMS="$PAR --host 10.10.1.$node_subnet_suffix --port 9$port_num_suffix$port_num_suffix$port_num_suffix"
        fi
        if [ "$STANDALONE" = true ];then
          PARAMS="$PAR  --host 10.10.1.5 --port 8983"
        fi
        echo "python3 traffic_gen.py $THREADS $PARAMS >/dev/null 2>&1 &" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh

      done
      if [ $l -eq 0 ];then
        echo "python3 traffic_gen.py $THREADS $PARAMS >/dev/null 2>&1" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh
      fi

    done
  fi

############## BACKGROUND DONE

# #### FIX THIS CAN BE REFACTORED TO BE MUCH MORE SUCCINCT
#
#   ####### THIS IS FOR FOREGROUND NODE
#   LUCKY_LOAD=${LOAD_NODES[$(($LOADSIZE-1))]}
#   for ((i=1; i<$(($procs)); i++)); do
#     # if more than 1 node, then the nodes subsequent to the first always have the max three threads for optimal parallelism
#     node_subnet_suffix=$(($(($i % $SOLR_SIZE))+1))
#     # this port suffix thing is really just for solrj requests since solrj has multiple ports to serve requests
#     port_num_suffix=$((($i % 4)+1))
#     if [ "$SOLRJ_PORT_OVERRIDE" = true ];then
#       port_num_suffix=4
#     fi
#     if [ "$INSTANCES_BOOL" = true ];then
#       PARAMS="$SINGLE_PAR  --host 10.10.1.$node_subnet_suffix --port ${single_instance_port_arr[$(($i % 4))]}"
#     else
#       PARAMS="$PAR --host 10.10.1.$node_subnet_suffix --port 9$port_num_suffix$port_num_suffix$port_num_suffix"
#     fi
#     if [ "$STANDALONE" = true ];then
#       PARAMS="$PAR  --host 10.10.1.5 --port 8983"
#     fi
#   	echo "python3 traffic_gen.py $THREADS $PARAMS >/dev/null 2>&1 &" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh
#   done
  #
  # node_subnet_suffix=$(($(($procs % $SOLR_SIZE))+1))
  # port_num_suffix=$((($procs % 4)+1))
  # if [ "$SOLRJ_PORT_OVERRIDE" = true ];then
  #   port_num_suffix=4
  # fi
  # if [ "$INSTANCES_BOOL" = true ];then
  #   PARAMS="$SINGLE_PAR  --host 10.10.1.$node_subnet_suffix --port ${single_instance_port_arr[$(($procs % 4))]}"
  # else
  #   PARAMS="$PAR --host 10.10.1.$node_subnet_suffix --port 9$port_num_suffix$port_num_suffix$port_num_suffix"
  # fi
  # if [ "$STANDALONE" = true ];then
  #   PARAMS="$PAR  --host 10.10.1.5 --port 8983"
  # fi
  # echo "python3 traffic_gen.py $THREADS $PARAMS >/dev/null 2>&1" >> $RSCRIPTS/${LUCKY_LOAD}/remotescript.sh
  #

  ####### FOREGRIOUND DONE


# copy to respective load nodes
  if [ "$first_time" = yes ];then
    for noder in "${ALL_LOAD_NODES[@]}";do
      scp ${RSCRIPTS}/${noder}/remotescript.sh $USER@${noder}:/users/${USER}/traffic_gen/remotescript.sh
    done
  fi


  printf "\n"
  echo "******** EXP PRELIM STEPS COMPLETE!! ************"
  printf "\n"
  printf "\n"
  printf "\n"

  echo "********* STARTING EXPERIMENT *********"
  printf "\n"
  printf "\n"
  printf "\n"
#### RUNNING EXPERIMENTS #####
  echo "RUNNING THESE SHELL SCRIPTS ON LOAD NODES"
  easyreadcount=0
  for i in "${LOAD_NODES[@]}";do
    if [ "$easyreadcount" -eq 0 ];then
      echo "${i}::"
      cat $RSCRIPTS/${i}/remotescript.sh
      printf "\n"

    else
      echo "${i}::"
      head -n 5 $RSCRIPTS/${i}/remotescript.sh
      echo "......"
      printf "\n"
    fi

    ((easyreadcount+=1))

  done
  echo "nohup output to loadoutput.out"
  printf "\n"
  printf "\n"
  # BACKGROUND LOAD GEN NODES
#  nohup pssh -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_$(($LOADSIZE-1)) "cd $(basename $PY_SCRIPT); bash remotescript_net.sh"&
  nohup pssh -l $USER -h $PROJECT_HOME/ssh_files/pssh_traffic_node_file_$LOADSIZE "cd $(basename $PY_SCRIPT); bash remotescript.sh" > loadoutput.out
  wait $!
  echo "************* FINISHED EXP ****************"
#### FINISHED #####

  printf "\n"
  printf "\n"
  printf "\n"
  printf "\n"
  echo "************* STARTING POST EXP STEPS ****************"
  printf "\n"
  printf "\n"
  echo "copying exp results to profiling_data/proc_results/  ... "

  # wait for slow processes to complete (prolly not effective)
  sleep 2
  for i in "${LOAD_NODES[@]}"; do
      scp -q $USER@$i:~/traffic_gen/http_benchmark_${15}* $PROJECT_HOME/tests_v1/profiling_data/proc_results &
  done

  wait $!
  sleep 1
  printf "\n\n\n"
  echo "RUNNING READ RESULTS SCRIPT"
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
  zip -rq $PROJECT_HOME/tests_v1/${DATE}:::FCTS__query${15}_rf${11}_s${13}_clustersize${19}_threads${5}_proc${7}.zip $PROJECT_HOME/tests_v1/profiling_data/proc_results

  printf "\n\n\n "
  echo "****** COMPLETED POST EXP STEPS *******"
  printf "\n\n\n "


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
# this default remains when distributed solrcloud is run
INSTANCES="--instances 0"
LOAD="x x"


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
# start_experiment $USER $PY_SCRIPT
export procs=$procs
export SOLRJ_PORT_OVERRIDE=$SOLRJ_PORT_OVERRIDE
start_experiment $USER $PY_SCRIPT $TERMS $THREADS $PROCESSES $DURATION $REPLICAS $SHARDS $QUERY $LOOP $SOLRNUM $LOAD $INSTANCES

#start_experiment $USER $PY_SCRIPT "\"$PARAMETERS\""

exit
