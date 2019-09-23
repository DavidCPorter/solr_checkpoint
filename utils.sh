#!/bin/bash
alias clearlog='cd ~/projects/solrcloud; pssh -h hostsIps "echo ''>/var/solr/logs/solr_slow_requests.log"'
alias wipetraffic='pssh -H node3 "echo ''>traffic_gen/traffic_gen.log"'
alias viewtraffic='pssh -H node3 -P "tail -n 1000 traffic_gen/traffic_gen.log"'
alias search='pssh -h hostsIps -P "cat /var/solr/logs/solr_slow_requests.log"'
alias test='cd ~/Desktop/solrcloud-dev/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7'
alias play='cd ~/Desktop/solrcloud-dev; ansible-playbook -i inventory'
alias closedloop='cd ~/Desktop/solrcloud-dev/tests_v1; bash runtest.sh traffic_gen words.txt -t 1 -p 1 -c 1 -d 20 --query solrj --loop closed --user dporte7'
alias testlocal='cd ~/Desktop/solrcloud-dev/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7'
