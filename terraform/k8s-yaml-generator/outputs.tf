output "secret_yaml_db_credentials" {
  value     = data.template_file.secret_yaml_db_credentials.rendered
  sensitive = true
}

output "configmap_yaml_db_params" {
  value = data.template_file.configmap_yaml_db_params.rendered
}

output "job_yaml_create_db_schema" {
  value = data.template_file.job_yaml_create_db_schema.rendered
}

output "cronjob_yaml_insert_records" {
  value = data.template_file.cronjob_yaml_insert_records.rendered
}