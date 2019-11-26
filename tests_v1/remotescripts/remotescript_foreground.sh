#!/bin/bash
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.3 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.4 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.5 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.6 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.7 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.8 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.9 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.10 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.11 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.12 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.13 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.14 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.15 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.16 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 10 --duration 10 --replicas 64 --shards 1 --query direct --loop open --solrnum 16 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.1
