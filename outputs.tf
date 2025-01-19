# TODO: Update to the live hosted URL for the URLRadar service
output "urlradar_url" {
  value       = "http://${var.external_ip}:{${module.urlradar_svc.name}-port}"
  description = "The URL endpoint for the URLRadar service."
}

# Internal Prometheus URL for Grafana datasource configuration: http://prometheus-server.monitoring.svc.cluster.local
output "grafana_url" {
  value       = "http://${var.external_ip}:32000"
  description = "External URL for accessing the Grafana dashboard to visualize metrics collected by Prometheus."
}

