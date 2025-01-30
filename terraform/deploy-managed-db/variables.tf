variable "region" {
  type        = string
  description = "Linode region to deploy"
}

variable "image_type" {
  type        = string
  description = "The image type to deploy all nodes with."
}

variable "project_namespace" {
  type        = string
  description = "Used for labels"
}

variable "lke_allowed_ips" {
  type = list(string)
  description = "IP addresses for LKE nodes that can access the DB"
}

variable "user_defined_allowed_ips" {
  type = string
  description = "IP addresses provided by user input as comma delimited string"
  default = ""
}

variable "db_cluster_size" {
  type = number
  description = "The number of nodes to deploy in the database cluser"
  default = 1
}