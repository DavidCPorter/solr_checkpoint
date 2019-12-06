#!/bin/bash
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 1 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 2 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py 3 --duration 10 --replicas 4 --shards 1 --query direct --loop open --solrnum 2 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.1 >/dev/null 2>&1
