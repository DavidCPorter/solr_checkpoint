#!/bin/bash
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 4 --query direct --loop open --solrnum 2 --instances 2 --connections 1 --output-dir ./ --host 10.10.1.1 --port 9911 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 4 --query direct --loop open --solrnum 2 --instances 2 --connections 1 --output-dir ./ --host 10.10.1.1 --port 8983
