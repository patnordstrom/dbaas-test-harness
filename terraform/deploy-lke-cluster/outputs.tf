output "lke_cluster_id" {
  value = linode_lke_cluster.lke_test_cluster.id
}

output "lke_ip_addresses" {
  value = local.lke_ip_addresses
}