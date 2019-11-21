#! /bin/bash

PROJECT_HOME='/Users/dporter/projects/solrcloud'

# nohup pssh -i -P -l dporte7 -h /Users/dporter/projects/solrcloud/ssh_files/pssh_solr_node_file "rm -rf /users/dporte7/solr-8_0/solr/server/solr/reviews*"

echo "removing node_ dirs on server1"
pssh -h ~/projects/solrcloud/ssh_files/solr_single_node -l dporte7 -P "rm -rf $CLOUDHOME/node_*"
