#!/bin/bash
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.2 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.3 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.4 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.5 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.6 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.7 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.8 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.9 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.10 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.11 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.12 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9111 --host 10.10.1.13 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9222 --host 10.10.1.14 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9333 --host 10.10.1.15 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.16 &
python3 traffic_gen.py --threads 46 --duration 15 --replicas 2 --shards 16 --query solrj --loop open --solrnum 32 --connections 1 --output-dir ./ --port 9444 --host 10.10.1.17
