# Variables used in multiple templates

variable "project_namespace" {
  type        = string
  description = "used to assign k8s namespaces and mysql database name"
}

variable "container_image" {
  type        = string
  description = "The container image we will use to execute python scripts"
}

# Variables for secret-db-credentials.yaml

variable "db_username" {
  type        = string
  description = "The username for the MySQL DB"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "The password for the MySQL DB"
  sensitive   = true
}

# Variables for configmap-db-params.yaml

variable "db_host" {
  type        = string
  description = "The hostname for the master MySQL node"
}

variable "db_port" {
  type        = number
  description = "The port number for the master MySQL node"
}

variable "db_connect_timeout" {
  type        = number
  description = "The database connection timeout in seconds"
}