#!/bin/bash
INSTANCES=1
for i in `seq 0`; do
  echo "1"
  if [ $INSTANCES -eq "1" ]; then
    echo "ONLY SINGLE INSTANCE"
    break
  fi
  echo "2"
done
