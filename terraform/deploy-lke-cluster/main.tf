# resource "random_password" "root_pass" {
#   length  = 30
#   special = true
# }

# resource "linode_instance" "dbaas_test_harness" {
#   label            = var.dbaas_test_harness_label
#   region           = var.region
#   image            = var.image_name
#   type             = var.dbaas_test_harness_image_type
#   root_pass        = random_password.root_pass.result
#   authorized_users = var.authorized_users
#   metadata {
#     user_data = filebase64("../cloud-init/dbaas-test-harness-config.yaml")
#   }
# }

# resource "linode_firewall" "pg_test_harness_fw" {
#   label           = "${var.dbaas_test_harness_label}-fw"
#   inbound_policy  = "DROP"
#   outbound_policy = "ACCEPT"

#   inbound {
#     label    = "allow-ssh-from-my-computer"
#     action   = "ACCEPT"
#     protocol = "TCP"
#     ports    = "22"
#     ipv4     = var.allowed_ssh_user_ips
#   }

#   linodes = [linode_instance.pg_test_harness.id]
# }

resource "linode_lke_cluster" "lke_test_cluster" {
  label       = var.lke_cluster_label
  k8s_version = var.k8s_version
  region      = var.region

  pool {
    type  = var.lke_image_type
    count = 1
  }

}