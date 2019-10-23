#!/bin/bash
alias wipetraffic='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 "echo ''>traffic_gen/traffic_gen.log"'
alias viewtraffic='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 -P "tail -n 2000 traffic_gen/traffic_gen.log"'
alias viewsolrj='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file_8 -P "tail -n 2000 solrclientserver/solrjoutput.txt"'
alias search='cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_zoo_node_file -P "tail -n 500 /var/solr/logs/solr.log"'
alias play='cd ~/projects/solrcloud; ansible-playbook -i inventory'
alias runsolrj='cd ~/projects/solrcloud;nohup pssh -P -i -h ssh_files/pssh_traffic_node_file_8 -l dporte7 "cd solrclientserver;java -cp target/solrclientserver-1.0-SNAPSHOT.jar com.dporte7.solrclientserver.DistributedWebServer > solrjoutput.txt" &'
alias killsolrj='cd ~/projects/solrcloud;pssh -i -h ssh_files/pssh_traffic_node_file_8 -l dporte7 $KILLARGS'
export KILLARGS="ps aux | grep -i solrclientserver | awk -F' ' '{print \$2}' | xargs kill -9"
alias clearout="cd ~/projects/solrcloud/tests_v1; echo ''> nohup.out"
alias viewout="cd ~/projects/solrcloud/tests_v1; tail -n 1000 nohup.out"
alias checksolrj='cd ~/projects/solrcloud;pssh -P -i -h ssh_files/pssh_traffic_node_file_8 -l dporte7 $CHECKARGS'
export CHECKARGS="ps aux | grep -i solrclientserver"
alias prime="cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf profiling_data/exp_results ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf profiling_data/exp_results/*;cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf *.zip ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip"
alias delete_collections="python3 /Users/dporter/projects/solrcloud/delete_collection.py"
alias force_delete='nohup pssh -i -P -l dporte7 -h /Users/dporter/projects/solrcloud/ssh_files/pssh_solr_node_file "rm -rf /users/dporte7/solr-8_0/solr/server/solr/reviews*"'
alias singlelogs="cd /Users/dporter/projects/solrcloud/; pssh -l dporte7 -h ssh_files/solr_single_node -P 'tail -n 1000 /var/solr/logs/solr.log'"

alias archive_prev="cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf profiling_data/exp_results ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf profiling_data/exp_results/*"

alias archive_fcts="cd /Users/dporter/projects/solrcloud/tests_v1;cp -rf *.zip ~/exp_results/$(date '+%Y-%m-%d_%H:%M');rm -rf *.zip"
shopt -s expand_aliases

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
    pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "bash ~/solr-8_0/solr/bin/solr stop -cloud -q -s ~/node__$i/solr -p 99$i$i -Dhost=10.10.1.1" &
  done

  sleep 8
  echo "removing old node_ dirs on server1"
  pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "rm -rf $CLOUDHOME/node_*"
  sleep 2
}
