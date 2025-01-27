resource "helm_release" "cloud_firewall_crd" {
  name       = "cloud-firewall-crd"
  repository = "https://linode.github.io/cloud-firewall-controller"
  chart      = "cloud-firewall-crd"
}

resource "helm_release" "cloud_firewall_ctrl" {
  name       = "cloud-firewall-ctrl"
  repository = "https://linode.github.io/cloud-firewall-controller"
  chart      = "cloud-firewall-controller"
  depends_on = [helm_release.cloud_firewall_crd]
}

resource "local_sensitive_file" "kubeconfig" {
  content  = base64decode(data.linode_lke_cluster.lke_cluster.kubeconfig)
  filename = "${path.module}/../../deploy/kubeconfig.yaml"
}