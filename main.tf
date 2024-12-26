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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "19.0.0"

  values = [
    <<EOF
alertmanager:
  enabled: true
server:
  persistentVolume:
    enabled: false
  extraScrapeConfigs:
    - job_name: 'kubernetes-cadvisor'
      kubernetes_sd_configs:
        - role: node
      metrics_path: /metrics/cadvisor
      relabel_configs:
        - source_labels: [__meta_kubernetes_node_name]
          target_label: node
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        - source_labels: [__meta_kubernetes_pod_name]
          target_label: pod_name
EOF
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.58.2"

  values = [
    <<EOF
service:
  type: NodePort
  port: 3000
  nodePort: 32000
persistence:
  enabled: false
adminUser: "admin"
adminPassword: "admin"
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local
EOF
  ]

  depends_on = [
    helm_release.prometheus
  ]
}

output "nginx_deployment_name" {
  value = module.nginx_deployment.deployment_name
}

output "nginx_service_name" {
  value = module.nginx_service.service_name
}

output "grafana_url" {
  value       = "http://<node-ip>:32000" # Control plane node IP
  description = "Access Grafana using this URL"
}

output "prometheus_url" {
  value       = "http://prometheus-server.monitoring.svc.cluster.local"
  description = "Prometheus endpoint in the cluster"
}
