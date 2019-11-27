#!/bin/bash

CLOUDHOME="/users/dporte7"
USER="dporte7"
# load sugar
# source /Users/dporter/projects/solrcloud/utils/utils.sh





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

getZnode (){
  case $1 in

    2)
      echo "/twoNode"
      ;;

    4)
      echo "/fourNode"
      ;;

    8)
      echo "/eightNode"
      ;;
    16)
      echo "/sixteenNode"
      ;;

    *)
      echo "ERROR: Failed to parse znode $1. Please recheck the variables"
      ;;
  esac
}

restartSolrJ () {
  echo "restarting SOLRJ"
  printf "\n\n"
  echo "stopping SOLRJ"
  killsolrj
  sleep 6

  printf "\n\n"

  # echo "starting SOLRJ $((getZnode $1))"
  printf "\n\n"
  runsolrj $(getZnode $1)
  wait $!
  sleep 4

}




containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
