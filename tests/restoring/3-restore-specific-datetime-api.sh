#!/usr/bin/env bash

### load variables and set configs ###

set -Eeuo pipefail

_script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
_deploy_dir="${_script_dir}/../../deploy"
_this_filename="$(echo ${BASH_SOURCE} | sed 's#^./##g' | cut -d . -f 1)"

source ${_deploy_dir}/vars.sh

### functions ###

function post_databases_mysql_instances {
  
  request_data_filename="3-post-databases-mysql-instances"

  post_request_result=$( \
    curl  --silent \
          --trace-ascii "${request_data_filename}-$(date +%s).curltrace" \
          --trace-time \
          --output /dev/null \
          --write-out "%{http_code}" \
          --request POST \
          --url https://api.linode.com/v4/databases/mysql/instances \
          --header "accept: application/json" \
          --header "content-type: application/json" \
          --header "authorization: Bearer ${LINODE_TOKEN}" \
          --data "@${request_data_filename}.json"
  )

  echo "HTTP Response Code: ${post_request_result}"

}

### main script ###

post_databases_mysql_instances