provider "kubernetes" {
  host        = trimspace(var.control_plane_node_host)
  config_path = trimspace(var.kube_config_path)
}

module "nginx_deployment" {
  source                          = "./modules/deployment"
  name                            = "nginx"
  app_label                       = "MyTestApp"
  image                           = "nginx"
  container_name                  = "nginx-container"
  replicas                        = 3
  container_port                  = 80
  cpu_limit                       = "500m"
  memory_limit                    = "512Mi"
  cpu_request                     = "250m"
  memory_request                  = "256Mi"
  liveness_probe_path             = "/"
  liveness_initial_delay_seconds  = 10
  liveness_period_seconds         = 5
  readiness_probe_path            = "/"
  readiness_initial_delay_seconds = 5
  readiness_period_seconds        = 5
}

module "nginx_service" {
  source      = "./modules/service"
  name        = "nginx"
  app_label   = module.nginx_deployment.deployment_app_label
  port        = 80
  target_port = 80

  depends_on = [
    module.nginx_deployment
  ]
}

output "nginx_deployment_name" {
  value = module.nginx_deployment.deployment_name
}

output "nginx_service_name" {
  value = module.nginx_service.service_name
}
