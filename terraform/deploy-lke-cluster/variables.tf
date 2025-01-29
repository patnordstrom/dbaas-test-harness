variable "region" {
  type        = string
  description = "Linode region to deploy"
}

variable "image_type" {
  type        = string
  description = "The image type to deploy all nodes with."
}

variable "k8s_version" {
  type        = string
  description = "The version of LKE to deploy."
}

variable "project_namespace" {
  type        = string
  description = "Used for labels"
}

variable "lke_cluster_size" {
  type = number
  description = "Size of node pool for LKE"
  default = 1
}