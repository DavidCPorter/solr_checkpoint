#!/bin/bash
for k in `seq 1 4`; do
  if [ $k == '3' ]; then
    continue
  fi
  echo "hey$k"
done
