#!/bin/bash
python3 traffic_gen.py --host 127.0.0.1 --port 9222 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9333 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9111 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9222 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9333 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9111 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9222 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
python3 traffic_gen.py --host 127.0.0.1 --port 9333 --threads 20 --duration 20 --connections 1 --query solrj --loop open --output-dir ./> /dev/null 2>&1 &
