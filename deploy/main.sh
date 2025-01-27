#!/usr/bin/env bash

### load variables and set configs ###

set -Eeuo pipefail

source ./vars.sh

_script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
_k8s_yaml_dir="${_script_dir}/k8s-yaml"
_python_scripts_dir="${_script_dir}/../scripts"
_terraform_yaml_generator_dir="$_script_dir/../terraform/k8s-yaml-generator"
_k8s_yaml_templates=('secret_yaml_db_credentials' 'configmap_yaml_db_params' 'job_yaml_create_db_schema')


### declare functions ###

function validate_variables {
  if [[ "${PROJECT_NAMESPACE}" =~ [^a-z] ]]; then
   echo "PROJECT_NAMESPACE contains invalid characters.  Please read the comment in the vars configuration file."
   exit 1
  fi
}

function init_working_directory {

  mkdir -p "${_k8s_yaml_dir}"
  export KUBECONFIG="${_script_dir}/kubeconfig.yaml"

}

function deploy_lke_cluster {
  echo "LKE cluster deployed"
}

function deploy_lke_firewall_controller {
  echo "LKE firewall controller deployed"
}

function generate_k8s_yaml_from_templates {
  let template_num=1

  # generate k8s yaml
  terraform -chdir="${_terraform_yaml_generator_dir}" apply \
    -auto-approve \
    -var "db_username=${DB_USERNAME}" \
    -var "db_password=${DB_PASSWORD}" \
    -var "db_host=${DB_HOST}" \
    -var "db_port=${DB_PORT}" \
    -var "db_connect_timeout=${DB_CONNECT_TIMEOUT}" \
    -var "project_namespace=${PROJECT_NAMESPACE}" \
    -var "container_image=${CONTAINER_IMAGE}"
  
  # write yaml outputs to working directory
  for item in "${_k8s_yaml_templates[@]}"
  do
    terraform -chdir="${_terraform_yaml_generator_dir}" output \
      -raw \
      ${item} \
      > ${_k8s_yaml_dir}/${template_num}_${item}.yaml
    let template_num++
  done

}

function create_k8s_resources {

  kubectl create namespace ${PROJECT_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
  
  kubectl create configmap python-scripts -n ${PROJECT_NAMESPACE} --from-file=${_python_scripts_dir}
  
  kubectl apply -f ${_k8s_yaml_dir}

}



### main script ###

validate_variables

init_working_directory

deploy_lke_cluster

deploy_lke_firewall_controller

generate_k8s_yaml_from_templates

create_k8s_resources






