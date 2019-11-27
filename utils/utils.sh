#!/bin/bash
alias mechart="python3 /Users/dporter/projects/solrcloud/chart/chartit_error_bars.py"
alias killmalware='cd ~/projects/solrcloud;pssh -i -h ssh_files/pssh_solr_node_file -l dporte7 -P sudo pkill -f'
alias fulllogs="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -h ssh_files/pssh_solr_node_file -P 'tail -n 100 /var/solr/logs/solr.log'"
alias grepnodeprocs="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -h ssh_files/pssh_solr_node_file -P 'ps aux | grep'"
alias callingnodes="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -h ssh_files/pssh_solr_node_file -P"
alias wipetraffic='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 "echo ''>traffic_gen/traffic_gen.log"'
alias viewtraffic='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 -P "tail -n 2000 traffic_gen/traffic_gen.log"'
alias viewsolrj='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 -P "tail -n 2000 solrclientserver/solrjoutput.txt"'
alias search='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_zoo_node_file -P "tail -n 500 /var/solr/logs/solr.log"'
alias play='cd ~/projects/solrcloud/playbooks; ansible-playbook -i ../inventory'
alias killsolrj='cd ~/projects/solrcloud;pssh -i -h ssh_files/pssh_traffic_node_file_8 -l dporte7 $KILLARGS'
export KILLARGS="ps aux | grep -i solrclientserver | awk -F' ' '{print \$2}' | xargs kill -9"
alias clearout="cd ~/projects/solrcloud/tests_v1; echo ''> nohup.out"
alias viewout="cd ~/projects/solrcloud/tests_v1; tail -n 1000 nohup.out"
alias checksolrj='cd ~/projects/solrcloud;pssh -i -h ssh_files/pssh_traffic_node_file_8 -l dporte7 $CHECKARGS'
alias checksolr='cd ~/projects/solrcloud;pssh -i -h ssh_files/pssh_solr_node_file -l dporte7 $CHECKSOLRARGS'
alias checkports='cd ~/projects/solrcloud;pssh -i -h ssh_files/solr_single_node -l dporte7 $CHECKPORTSARGS'
export CHECKSOLRARGS="ps aux | grep solr"
export CHECKPORTSARGS="lsof -i | grep LISTEN"

export CHECKARGS="ps aux | grep -i solrclientserver"
alias prime="cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf profiling_data/exp_results ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf profiling_data/exp_results/*;cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf *.zip ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip"
# alias delete_collections="python3 /Users/dporter/projects/solrcloud/utils/delete_collection.py"
alias force_delete_all='play solr_configure_16.yml --tags solr_stop;nohup pssh -i -P -l dporte7 -h /Users/dporter/projects/solrcloud/ssh_files/pssh_solr_node_file "rm -rf /users/dporte7/solr-8_0/solr/server/solr/reviews*"'
alias singlelogs="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -h ssh_files/solr_single_node -P 'tail -n 1000 /var/solr/logs/solr.log'"



alias archive_fcts="cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf *.zip ~/exp_results_fct_zips/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip"
alias singletest="cd /Users/dporter/projects/solrcloud/tests_v1; bash exp_single_cluster.sh"
alias fulltest="cd /Users/dporter/projects/solrcloud/tests_v1; bash exp_scale_loop.sh"
alias listcores="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -i -h ssh_files/pssh_solr_node_file 'ls /users/dporte7/solr-8_0/solr/server/solr'"
alias deldown="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -i -h ssh_files/solr_single_node 'bash /users/dporte7/solr-8_0/solr/bin/solr delete -c'"
alias checkdisk="cd /Users/dporter/projects/solrcloud/; pssh -h ssh_files/pssh_solr_node_file -l dporte7 -P 'df | grep /dev/nvme0n1p1'"

alias checkconfig="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -i -h ssh_files/solr_single_node 'cat /users/dporte7/solr-8_0/solr/server/solr/configsets/_default/conf/solrconfig.xml'"
alias collectionconfig="curl http://128.110.153.162:8983/solr/reviews_rf4_s1_clustersize94/config"
alias collectionconfigfull="curl http://128.110.153.162:8983/solr/reviews_rf32_s1_clustersize16/config"

CORE_HOME=/users/dporte7/solr-8_0/solr/server/solr

node0=128.110.153.162
node1=128.110.153.184
node2=128.110.153.165
node3=128.110.153.161
node4=128.110.153.197
node5=128.110.153.173
node6=128.110.153.204
node7=128.110.153.166
node8=128.110.153.187
node9=128.110.153.160
node10=128.110.153.212
node11=128.110.153.198
node12=128.110.153.218
node13=128.110.153.164
node14=128.110.153.169
node15=128.110.153.170
node16=128.110.153.163
node17=128.110.153.154
node18=128.110.153.167
node19=128.110.153.189
node20=128.110.153.188
node21=128.110.153.217
node22=128.110.153.176
node23=128.110.153.172

alias ssher="ssh -l dporte7"
shopt -s expand_aliases

alias wipecores="callingnodes rm -rf /users/dporte7/solr-8_0/solr/server/solr/reviews*"

EXP_HOME=/Users/dporter/projects/solrcloud/chart/exp_records

runsolrj (){
  pssh -h ~/projects/solrcloud/ssh_files/pssh_traffic_node_file_8 -l dporte7 "cd solrclientserver;java -cp target/solrclientserver-1.0-SNAPSHOT.jar com.dporte7.solrclientserver.DistributedWebServer $1 > solrjout.log 2>&1 &"&
}

archivePrev (){
  cd /Users/dporter/projects/solrcloud/tests_v1
  mkdir $EXP_HOME/$1
  cp -rf profiling_data/exp_results/* $EXP_HOME/$1
  rm -rf profiling_data/exp_results/*
}

stopsingle (){
  for i in `seq 8`;do
    printf "\n STOPPING SOLR INSTANCES:"
    echo "node__$i/solr -p 99$i$i"
    pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "bash ~/solr-8_0/solr/bin/solr stop -cloud -q -s ~/node__$i/solr -p 99$i$i -Dhost=10.10.1.1"
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
    pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "bash ~/solr-8_0/solr/bin/solr stop -cloud -q -s ~/node__$i/solr -p 99$i$i -Dhost=10.10.1.1"
  done

  sleep 8
  echo "removing old node_ dirs on server1"
  pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "rm -rf $CLOUDHOME/node_*"
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

startSolr () {
  printf "\n\n"
  echo "starting zookeeper and solr "
  printf "\n\n"
  play solr_configure_$1.yml --tags solr_start
  wait $!
  sleep 3
}
