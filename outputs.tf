output "urlradar_url" {
  value       = "http://${var.external_ip}:{${module.urlradar_svc.name}-port}"
  description = "The URL endpoint for the URLradar service"
}

output "prometheus_url" {
  value       = "http://prometheus-server.monitoring.svc.cluster.local"
  description = "Internal URL for accessing the Prometheus server within the Kubernetes cluster for metric collection and querying."
}

output "grafana_url" {
  value       = "http://${var.external_ip}:32000"
  description = "External URL for accessing the Grafana dashboard for visualizing metrics collected by Prometheus."
}
