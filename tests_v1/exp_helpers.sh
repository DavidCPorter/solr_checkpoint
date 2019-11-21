#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"
# load sugar
source /Users/dporter/projects/solrcloud/utils.sh

stopSolr () {
  printf "\n\n"
  echo "stopping solr "
  printf "\n\n"

  play solr_configure_16.yml --tags solr_stop
  wait $!
  sleep 3

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

restartSolr () {
  printf "\n\n"
  # zoo needs to be restarted in case clutersize changed
  echo "restarting solr and zookeeper "
  play solr_configure_$1.yml --tags solr_restart

}


resetExperiment () {
  printf "\n\n"
  echo "resetting experiment..."
  delete_collections 8983
  sleep 5

}


restartSolrJ () {
  echo "restarting SOLRJ"
  printf "\n\n"
  echo "stopping SOLRJ"
  killsolrj
  wait $!
  sleep 6

  printf "\n\n"
  echo "starting SOLRJ"
  printf "\n\n"
  runsolrj
  wait $!
  sleep 4

}




containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
