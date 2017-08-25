#!/bin/bash

set -e

TIMEOUT=120
COUNT=0
IP=${1:-`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`}
PORT=${2:-"5432"}

until pg_isready -h $IP -p $PORT || [ $COUNT -eq $TIMEOUT ];
do
  echo "Try #${COUNT} - Timeout ${TIMEOUT}s"
  sleep 1
  COUNT=$((COUNT+1))
done