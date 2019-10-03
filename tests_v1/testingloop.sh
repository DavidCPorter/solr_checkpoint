#!/bin/bash
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 16  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done

for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 32  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 16  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done

for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 32  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done

for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 16  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 32  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 16  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
for i in `seq 1 2 70`; do
  cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 32  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
  wait $!
  cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
  sleep 5
done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 32  -t ${i} -d 15 -p 32 --solrnum 32 --query solrj --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 8  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 2 -s 8  -t ${i} -d 15 -p 32 --solrnum 32 --query solrj --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 4  -t ${i} -d 15 -p 32 --solrnum 32 --query solrj --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 16  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 16  -t ${i} -d 15 -p 32 --solrnum 32 --query solrj --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done
# for i in `seq 10 10 110`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 32  -t ${i} -d 15 -p 32 --solrnum 32 --query direct --loop open
#   wait $!
#   cd ~/projects/solrcloud;pssh -l dporte7 -h ssh_files/pssh_traffic_node_file "echo ''>traffic_gen/traffic_gen.log"
#   sleep 10
# done

# for i in `seq 5 7 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 16  -t ${i} -d 15 -p 32 --query solrj --loop open
#   wait $!
#   sleep 10
# done
# for i in `seq 5 7 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 24  -t ${i} -d 15 -p 32 --query solrj --loop open
#   wait $!
#   sleep 10
# done
# for i in `seq 5 7 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 4 -s 32  -t ${i} -d 15 -p 32 --query solrj --loop open
#   wait $!
#   sleep 10
# done
# for i in `seq 5 7 50`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 6 -s 16  -t ${i} -d 15 -p 32 --query solrj --loop open
#   wait $!
#   sleep 10
# done
# for i in `seq 10 5 70`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 8 -s 8  -t ${i} -d 15 -p 32 --query direct --loop open
#   wait $!
#   sleep 5
# done
# for i in `seq 10 5 70`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 8 -s 12  -t ${i} -d 15 -p 32 --query direct --loop open
#   wait $!
#   sleep 5
# done
# for i in `seq 10 5 70`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 8 -s 16  -t ${i} -d 15 -p 32 --query direct --loop open
#   wait $!
#   sleep 5
# done
# for i in `seq 10 5 70`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 8 -s 32  -t ${i} -d 15 -p 32 --query direct --loop open
#   wait $!
#   sleep 5
# done
# for j in `seq 5 5 55`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 24  -t ${j} -d 15 -p 32 --query direct --loop open
#   wait $!
#   sleep 5
# done
# for k in `seq 5 5 55`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -rf 3 -s 32  -t ${k} -d 15 -p 32 --query direct --loop open
#   wait $!
#   sleep 5
# done
# done
# for j in `seq 2 2 10`; do
#   cd ~/projects/solrcloud/tests_v1; bash runtest.sh traffic_gen words.txt --user dporte7 -c 5 -t $(($j * 3)) -d 15 -p $(($j * 3))  --query direct --loop open
#   wait $!
#   sleep 10
# done
