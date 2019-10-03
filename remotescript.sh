#!/bin/bash
# this file is used to run processes remotely since cloudlab blacklists aggressive ssh
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.1 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.2 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.3 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.4 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.5 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.6 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.7 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.8 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.9 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.10 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.11 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.12 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.13 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.14 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.15 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.16 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.17 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.18 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.19 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.20 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.21 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.22 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.23 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.24 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.25 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.26 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.27 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9111 --host 10.10.1.28 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9222 --host 10.10.1.29 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9333 --host 10.10.1.30 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.31 >/dev/null 2>&1 &
python3 traffic_gen.py --threads 25 --duration 20 -rf 3 --shards 16 --query direct --loop open -c 1 --output-dir ./ --port 9444 --host 10.10.1.32 >/dev/null 2>&1 &