#!/bin/bash
# this file is used to run processes remotely since cloudlab blacklists aggressive ssh
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 4 --query direct --loop open --solrnum 2 --instances 2 --connections 1 --output-dir ./ --host 10.10.1.1 --port 9911 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 4 --query direct --loop open --solrnum 2 --instances 2 --connections 1 --output-dir ./ --host 10.10.1.1 --port 8983 >/dev/null 2>&1 &
