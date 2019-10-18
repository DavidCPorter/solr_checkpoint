#!/bin/bash


for j in `seq 2 5`; do
	SERVERS=$((2**$j))
	python3 chartit.py direct $SERVERS c$SERVERS
	wait $!	
	sleep 5
	python3 chartit.py solrj $SERVERS c$SERVERS
	wait $!	
	sleep 5
done
