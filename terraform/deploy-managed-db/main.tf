locals {
  allowed_ips = var.user_defined_allowed_ips == "" ? var.lke_allowed_ips : setunion(split(",",var.user_defined_allowed_ips),var.lke_allowed_ips)
}

resource "linode_database_mysql_v2" "mysql_db_test" {
  label = "${var.project_namespace}-db"
  engine_id = "mysql/8"
  region = var.region
  type = var.image_type

  allow_list = local.allowed_ips
  cluster_size = var.db_cluster_size
}