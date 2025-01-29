# Create the YAML for the Secret object for DB connectivity

data "template_file" "secret_yaml_db_credentials" {
  template = file("${path.module}/templates/secret-db-credentials.yaml")
  vars = {
    db_username       = base64encode(var.db_username)
    db_password       = base64encode(var.db_password)
    project_namespace = var.project_namespace
  }
}

# Create the YAML for the ConfigMap object for DB connectivity

data "template_file" "configmap_yaml_db_params" {
  template = file("${path.module}/templates/configmap-db-params.yaml")
  vars = {
    db_host            = var.db_host
    db_port            = var.db_port
    db_connect_timeout = var.db_connect_timeout
    project_namespace  = var.project_namespace
  }
}

# Create the YAML for the Job that creates the DB schema

data "template_file" "job_yaml_create_db_schema" {
  template = file("${path.module}/templates/job-create-db-schema.yaml")
  vars = {
    project_namespace = var.project_namespace
    container_image   = var.container_image
  }
}

# Create the YAML for the CronJob that inserts records to customers table

data "template_file" "cronjob_yaml_insert_records" {
  template = file("${path.module}/templates/cronjob-insert-records.yaml")
  vars = {
    project_namespace = var.project_namespace
    container_image   = var.container_image
  }
}