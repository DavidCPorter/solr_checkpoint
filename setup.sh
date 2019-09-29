#!/bin/bash

# cd ~/projects/solrcloud; ansible-playbook -i inventory cloud_configure.yml
# wait $!
# cd ~/projects/solrcloud; ansible-playbook -i inventory zoo_configure.yml
# wait $!
cd ~/projects/solrcloud; ansible-playbook -i inventory solr_configure.yml
wait $!
cd ~/projects/solrcloud; ansible-playbook -i inventory post_data.yml --extra-vars "shards=$2 replicas=$3"
wait $!
cd ~/projects/solrcloud; ansible-playbook -i inventory solr_bench.yml --tags local
