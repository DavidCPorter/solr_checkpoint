#!/bin/bash

cd ~/Desktop/solrcloud-dev; ansible-playbook -i inventory cloud_configure.yml
wait $!
cd ~/Desktop/solrcloud-dev; ansible-playbook -i inventory zoo_configure.yml
wait $!
cd ~/Desktop/solrcloud-dev; ansible-playbook -i inventory solr_configure.yml
wait $!
cd ~/Desktop/solrcloud-dev; ansible-playbook -i inventory post_data.yml
wait $!
cd ~/Desktop/solrcloud-dev; ansible-playbook -i inventory solr_bench.yml --tags local
