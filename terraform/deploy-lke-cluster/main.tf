resource "linode_lke_cluster" "lke_test_cluster" {
  label       = "${var.project_namespace}-lke"
  k8s_version = var.k8s_version
  region      = var.region

  pool {
    type  = var.image_type
    count = var.lke_cluster_size
  }

}

data "linode_instances" "lke_nodes" {
  filter {
    name   = "id"
    values = [for item in linode_lke_cluster.lke_test_cluster.pool[0].nodes : item.instance_id]
  }
}

locals {
  lke_ip_addresses = setunion(
    [for item in data.linode_instances.lke_nodes.instances : "${item.ip_address}/32"],
    [for item in data.linode_instances.lke_nodes.instances : "${item.ipv6}"]
  )
}