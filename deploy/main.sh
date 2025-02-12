#!/usr/bin/env bash

### load variables and set configs ###

set -Eeuo pipefail

source ./vars.sh

_script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
_k8s_yaml_dir="${_script_dir}/k8s-yaml"
_terraform_dir="${_script_dir}/../terraform"
_python_scripts_dir="${_script_dir}/../scripts"
_terraform_lke_deploy_dir="${_terraform_dir}/deploy-lke-cluster"
_terraform_firewall_dir="${_terraform_dir}/deploy-firewall"
_terraform_managed_db_dir="${_terraform_dir}/deploy-managed-db"
_terraform_yaml_generator_dir="${_terraform_dir}/k8s-yaml-generator"
_k8s_yaml_templates=('secret_yaml_db_credentials' 'configmap_yaml_db_params' 'job_yaml_create_db_schema' 'cronjob_yaml_insert_records')
_auto_approve_terraform_deployments="yes"
_upgrade_terraform_providers="no"


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

  # init the workspaces

  terraform -chdir="${_terraform_lke_deploy_dir}" init \
    $( if [ ${_upgrade_terraform_providers} == "yes" ]; then printf %s "-upgrade"; fi )
  
  terraform -chdir="${_terraform_firewall_dir}" init \
    $( if [ ${_upgrade_terraform_providers} == "yes" ]; then printf %s "-upgrade"; fi )


  # deploy the cluster

  terraform -chdir="${_terraform_lke_deploy_dir}" apply \
    $( if [ ${_auto_approve_terraform_deployments} == "yes" ]; then printf %s "-auto-approve"; fi ) \
    -var project_namespace="${PROJECT_NAMESPACE}" \
    -var region="${LINODE_REGION}" \
    -var image_type="${IMAGE_TYPE}" \
    -var k8s_version="${K8S_VERSION}" \
    -var lke_cluster_size="${LKE_CLUSTER_SIZE}"

  cluster_id=$(
    terraform -chdir="${_terraform_lke_deploy_dir}" output \
    -raw \
    lke_cluster_id
  )

  # apply firewall controller to cluster

  terraform -chdir="${_terraform_firewall_dir}" apply \
    -auto-approve \
    -var lke_cluster_id="${cluster_id}" 

}

function deploy_database {

  # init the workspaces
  
  terraform -chdir="${_terraform_managed_db_dir}" init \
    $( if [ ${_upgrade_terraform_providers} == "yes" ]; then printf %s "-upgrade"; fi )

  # deploy the DB cluster

  lke_ip_addresses=$(
    terraform -chdir="${_terraform_lke_deploy_dir}" output \
      -json \
      lke_ip_addresses
  )

  terraform -chdir="${_terraform_managed_db_dir}" apply \
    $( if [ ${_auto_approve_terraform_deployments} == "yes" ]; then printf %s "-auto-approve"; fi ) \
    -var project_namespace="${PROJECT_NAMESPACE}" \
    -var region="${LINODE_REGION}" \
    -var image_type="${IMAGE_TYPE}" \
    -var db_cluster_size="${DB_CLUSTER_SIZE}" \
    -var lke_allowed_ips="${lke_ip_addresses}" \
    -var user_defined_allowed_ips="${DB_ALLOWED_CIDRS}"

  # set variables required by other functions

  vars_to_set=("DB_USERNAME" "DB_PASSWORD" "DB_HOST" "DB_PORT")

  for item in "${vars_to_set[@]}"
  do
    declare -g ${item}=$(
    terraform -chdir="${_terraform_managed_db_dir}" output \
      -raw \
      $(echo "${item}" | tr '[:upper:]' '[:lower:]')
    )
    export ${item}
  done


}

function generate_k8s_yaml_from_templates {

  # init the workspaces
  
  terraform -chdir="${_terraform_yaml_generator_dir}" init \
    $( if [ ${_upgrade_terraform_providers} == "yes" ]; then printf %s "-upgrade"; fi )

  # generate k8s yaml

  terraform -chdir="${_terraform_yaml_generator_dir}" apply \
    $( if [ ${_auto_approve_terraform_deployments} == "yes" ]; then printf %s "-auto-approve"; fi ) \
    -var "db_username=${DB_USERNAME}" \
    -var "db_password=${DB_PASSWORD}" \
    -var "db_host=${DB_HOST}" \
    -var "db_port=${DB_PORT}" \
    -var "db_connect_timeout=${DB_CONNECT_TIMEOUT}" \
    -var "project_namespace=${PROJECT_NAMESPACE}" \
    -var "container_image=${CONTAINER_IMAGE}"
  
  # write yaml outputs to working directory
  # templates are numbered so they will process in the desired order
  # later in the script when we apply them with kubectl

  let template_num=1

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

  kubectl create configmap python-scripts -n ${PROJECT_NAMESPACE} --from-file=${_python_scripts_dir} -o yaml --dry-run=client | kubectl apply -f -
  
  kubectl apply -f ${_k8s_yaml_dir}

}



### main script ###

validate_variables

init_working_directory


if [ "${DEPLOY_LKE_CLUSTER}" == "yes" ]; then
  deploy_lke_cluster
else
  read \
    -p \
    "Press enter when you have confirmed you have a kubeconfig.yaml in the 'deploy' directory" \
    </dev/tty
fi

if [ "${DEPLOY_DB}" == "yes" ]; then
  deploy_database
else
  read \
    -p \
    "Press enter when you have finished adding LKE node IPs to your managed DB white list" \
    </dev/tty
fi

generate_k8s_yaml_from_templates

create_k8s_resources






