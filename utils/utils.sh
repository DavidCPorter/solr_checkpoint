#!/bin/bash
PROJ_HOME=/Users/dporter/projects/solrcloud
CL_USER=dporte7
CHECKSOLRARGS='ps aux | grep solr'
CHECKPORTSARGS='lsof -i | grep LISTEN'
KILLARGS="ps aux | grep -i solrclientserver | awk -F' ' '{print \$2}' | xargs kill -9"
CHECKARGS='ps aux | grep -i solrclientserver'

alias grepmal="cd $PROJ_HOME/; pssh -l $CL_USER -h ssh_files/pssh_solr_node_file -P 'ps aux | grep kdevtmpfsi > tmpout.txt;head -n 1 tmpout.txt'"
alias whatsgood="cd $PROJ_HOME/tests_v1/profiling_data/exp_results; ls -t; cat * */*;cd $PROJ_HOME" 
alias mechart="python3 $PROJ_HOME/chart/chartit_error_bars.py"
alias killallbyname="cd /Users/dporter/projects/solrcloud;pssh -i -h ssh_files/pssh_all -l dporte7 -P sudo pkill -f"
alias fulllogs="cd $PROJ_HOME/; pssh -l $CL_USER -h ssh_files/pssh_solr_node_file -P 'tail -n 100 /var/solr/logs/solr.log'"
alias grepnodeprocs="cd $PROJ_HOME/; pssh -l $CL_USER -h ssh_files/pssh_solr_node_file -P 'ps aux | grep'"
alias callingnodes="cd $PROJ_HOME/; pssh -l $CL_USER -h ssh_files/pssh_all -P"
alias wipetraffic="cd $PROJ_HOME;pssh -l $CL_USER -h ssh_files/pssh_traffic_node_file 'echo hey >traffic_gen/traffic_gen.log'"
alias viewtraffic="cd $PROJ_HOME;pssh -l $CL_USER -h ssh_files/pssh_traffic_node_file -P 'tail -n 2000 traffic_gen/traffic_gen.log'"
alias viewsolrj="cd $PROJ_HOME;pssh -l $CL_USER -h ssh_files/pssh_traffic_node_file -P 'tail -n 2000 solrclientserver/solrjoutput.txt'"
alias play="cd $PROJ_HOME/playbooks; ansible-playbook -i ../inventory"
alias killsolrj='cd $PROJ_HOME;pssh -i -h ssh_files/pssh_traffic_node_file -l $CL_USER $KILLARGS'
alias clearout="cd $PROJ_HOME/tests_v1; echo ''> nohup.out"
alias viewout="cd $PROJ_HOME/tests_v1; tail -n 1000 nohup.out"
alias checksolrj="cd $PROJ_HOME;pssh -i -h ssh_files/pssh_traffic_node_file -l $CL_USER $CHECKARGS"
alias checksolr="cd $PROJ_HOME;pssh -i -h ssh_files/pssh_solr_node_file -l $CL_USER $CHECKSOLRARGS"
alias checkports="cd $PROJ_HOME;pssh -i -h ssh_files/solr_single_node -l $CL_USER $CHECKPORTSARGS"
alias checkcpu="cd $PROJ_HOME/; pssh -l $CL_USER -h ssh_files/pssh_solr_node_file -P 'top -bn1 > cpu.txt;head -10 cpu.txt'"
# alias delete_collections="python3 $PROJ_HOME/utils/delete_collection.py"
alias singlelogs="cd $PROJ_HOME/; pssh -l $CL_USER -h ssh_files/solr_single_node -P 'tail -n 1000 /var/solr/logs/solr.log'"

# alias archive_fcts="cd $PROJ_HOME/tests_v1;cp -rf *.zip ~/exp_results_fct_zips/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip"
alias singletest="cd $PROJ_HOME/tests_v1; bash exp_single_cluster.sh"
alias fulltest="cd $PROJ_HOME/tests_v1; bash exp_scale_loop.sh"
alias listcores="cd $PROJ_HOME/; pssh -l $CL_USER -i -h ssh_files/pssh_solr_node_file 'ls /users/$CL_USER/solr-8_0/solr/server/solr'"
alias deldown="cd $PROJ_HOME/; pssh -l $CL_USER -i -h ssh_files/solr_single_node 'bash ~/solr-8_0/solr/bin/solr delete -c'"
alias checkdisk="cd $PROJ_HOME/; pssh -h ssh_files/pssh_solr_node_file -l $CL_USER -P 'df | grep /dev/nvme0n1p1'"

alias checkconfig="cd $PROJ_HOME/; pssh -l $CL_USER -i -h ssh_files/solr_single_node 'cat ~/solr-8_0/solr/server/solr/configsets/_default/conf/solrconfig.xml'"
alias collectionconfig="curl http://128.110.153.162:8983/solr/reviews_rf4_s1_clustersize94/config"
alias collectionconfigfull="curl http://128.110.153.162:8983/solr/reviews_rf32_s1_clustersize16/config"

export CORE_HOME=/users/dporte7/solr-8_0/solr/server/solr


export node0='128.110.153.169'
export node1='128.110.153.193'
export node2='128.110.153.240'
export node3='128.110.153.108'
export node4='128.110.153.224'
export node5='128.110.153.131'
export node6='128.110.153.167'
export node7='128.110.153.184'
export node8='128.110.153.189'
export node9='128.110.153.84'
export node10='128.110.153.154'
export node11='128.110.153.165'
export node12='128.110.153.164'
export node13='128.110.153.192'
export node14='128.110.153.181'
export node15='128.110.153.217'
export node16='128.110.153.179'
export node17='128.110.153.190'
export node18='128.110.153.230'
export node19='128.110.153.173'
export node20='128.110.153.166'
export node21='128.110.153.227'
export node22='128.110.153.136'
export node23='128.110.153.172'
export node24='128.110.153.91'
export node25='128.110.153.125'
export node26='128.110.153.212'
export node27='128.110.153.176'
export node28='128.110.153.182'
export node29='128.110.153.208'
export node30='128.110.153.177'
export node31='128.110.153.161'
export node32='128.110.153.162'
export node33='128.110.153.225'
export node34='128.110.153.163'
export node35='128.110.153.180'
export node36='128.110.153.187'
export node37='128.110.153.198'
export node38='128.110.153.170'
export node39='128.110.153.222'

export ALL_NODES=" $node0 $node1 $node2 $node3 $node4 $node5 $node6 $node7 $node8 $node9 $node10 $node11 $node12 $node13 $node14 $node15 $node16 $node17 $node18 $node19 $node20 $node21 $node22 $node23 $node24 $node25 $node26 $node27 $node28 $node29 $node30 $node31 $node32 $node33 $node34 $node35 $node36 $node37 $node38 $node39 "

export ALL_SOLR=" $node0 $node1 $node2 $node3 $node4 $node5 $node6 $node7 $node8 $node9 $node10 $node11 $node12 $node13 $node14 $node15 "
export ALL_LOAD=" $node16 $node17 $node18 $node19 $node20 $node21 $node22 $node23 $node24 $node25 $node26 $node27 $node28 $node29 $node30 $node31 $node32 $node33 $node34 $node35 $node36 $node37 $node38 $node39 "

alias ssher="ssh -l $CL_USER"
shopt -s expand_aliases

wipecores () {
  pssh -h $PROJ_HOME/ssh_files/pssh_solr_node_file -l $CL_USER rm -rf $CORE_HOME/reviews*
}

wipecores_backup () {
  for i in $ALL_SOLR; do
    ssh $CL_USER@$i rm -rf $CORE_HOME/reviews*
  done
}

EXP_HOME=$PROJ_HOME/chart/exp_records
# just deal with it... find and replace snafu. they are the same
export PROJECT_HOME=/Users/dporter/projects/solrcloud

runsolrj (){
  pssh -h $PROJ_HOME/ssh_files/pssh_traffic_node_file -l $CL_USER "cd solrclientserver;java -cp target/solrclientserver-1.0-SNAPSHOT.jar com.dporte7.solrclientserver.DistributedWebServer $1 > javaServer.log 2>&1 &"&
}

archivePrev (){
  cd $PROJ_HOME/tests_v1
  mkdir $EXP_HOME/$1
  cp -rf profiling_data/exp_results/* $EXP_HOME/$1
  rm -rf profiling_data/exp_results/*
  cp -rf *.zip $EXP_HOME/$1
  rm -rf *.zip
}

stopsingle (){
  for i in `seq 8`;do
    printf "\n STOPPING SOLR INSTANCES:"
    echo "node__$i/solr -p 99$i$i"
    pssh -h $PROJ_HOME/ssh_files/solr_single_node -l $CL_USER -P "bash ~/solr-8_0/solr/bin/solr stop -cloud -q -s ~/node__$i/solr -p 99$i$i -Dhost=10.10.1.1"
  done
}


wipeInstances (){
  # clean wipe state of singlesolr
  echo "wipe state of single solr by deleting collections, stopping instances, and removing solrhome of instances"
  printf "\n\n"

  echo "deleting previous collections"
  delete_collections 9911
  wait $!
  sleep 5
  printf "\n\n"
  # # just to be safe dont want to duplicate cores
  # force_delete
  # sleep 3

  for i in `seq 8`;do
    printf "\n STOPPING SOLR INSTANCES:"
    echo "node__$i/solr -p 99$i$i"
    pssh -h $PROJ_HOME/ssh_files/solr_single_node -l $CL_USER -P "bash ~/solr-8_0/solr/bin/solr stop -cloud -q -s ~/node__$i/solr -p 99$i$i -Dhost=10.10.1.1"
  done

  sleep 8
  echo "removing old node_ dirs on server1"
  pssh -h $PROJ_HOME/ssh_files/solr_single_node -l $CL_USER -P "rm -rf $CLOUDHOME/node_*"
  sleep 2
}


stopSolr () {
  printf "\n\n"
  echo "stopping solr "
  printf "\n\n"

  play solr_configure_$1.yml --tags solr_stop
  sleep 5

  # play zoo_configure.yml --tags zoo_stop
  # wait $!
  # sleep 3

}

resetState () {
  stopSolr $1
  wipecores
  play zoo_configure.yml --tags zoo_stop
  play zoo_configure.yml --tags zoo_start
}

startSolr () {
  printf "\n\n"
  echo "starting zookeeper and solr "
  printf "\n\n"
  play solr_configure_$1.yml --tags solr_start
  sleep 3
}

#to kill malware
#pssh -l dporte7 -h ssh_files/pssh_solr_node_file -P sudo rm -rf /tmp/.ICEd* /tmp/kdevtmpfsi;pssh -l dporte7 -h ssh_files/pssh_solr_node_file -P sudo pkill -f .ICEd;pssh -l dporte7 -h ssh_files/pssh_solr_node_file -P sudo pkill -f kdevtmpfsi
