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

output "urlradar_svc_name" {
  value = module.urlradar_svc.service_name
}
