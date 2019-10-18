#! /bin/bash

PROJECT_HOME='/Users/dporter/projects/solrcloud'

nohup pssh -i -P -l dporte7 -h $PROJECT_HOME/ssh_files/pssh_solr_node_file "rm -rf /users/dporte7/solr-8_0/solr/server/solr/reviews*"
