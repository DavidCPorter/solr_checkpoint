#!/bin/bash
alias clearlog='pssh -h hostsIps "echo ''>/var/solr/logs/solr_slow_requests.log"'
alias search='pssh -h hostsIps -P "cat /var/solr/logs/solr_slow_requests.log | grep"'
alias test='cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt -c 5 --user dporte7'
alias play='ansible-playbook -i inventory'
