output "name" {
  value       = kubernetes_service.this.metadata[0].name
  description = "The name of the Kubernetes service."
}
