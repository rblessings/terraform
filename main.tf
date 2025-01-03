provider "kubernetes" {
  host        = trimspace(var.control_plane_node_host)
  config_path = trimspace(var.kube_config_path)
}

provider "helm" {
  kubernetes {
    host        = trimspace(var.control_plane_node_host)
    config_path = trimspace(var.kube_config_path)
  }
}
