#!/bin/bash
# this file is used to run processes remotely since cloudlab blacklists aggressive ssh
python3 traffic_gen.py --threads 8 --duration 10 --replicas 8 --shards 2 --query solrj --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 8 --duration 10 --replicas 8 --shards 2 --query solrj --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
