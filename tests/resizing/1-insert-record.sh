#!/usr/bin/env bash

### load variables and set configs ###

source vars.sh

_iterations=1000

### functions ###

function insert_record {
  docker run \
  -v $(pwd):/test-artifacts \
  -e DB_USERNAME=${DB_USERNAME} \
  -e DB_PASSWORD=${DB_PASSWORD} \
  -e DB_HOST=${DB_HOST} \
  -e DB_PORT=${DB_PORT} \
  -e DB_SCHEMA=${DB_SCHEMA} \
  -e DB_CONNECT_TIMEOUT=${DB_CONNECT_TIMEOUT} \
  pnordstrom/dbaas-test-harness:0.3 ./1-insert-record.py
}


for i in $(seq 1 ${_iterations});
  do
  echo $(date '+%Y-%m-%d %H:%M:%S') | tee -a ./1-insert-record.log
  insert_record 2>&1 | tee -a ./1-insert-record.log
done