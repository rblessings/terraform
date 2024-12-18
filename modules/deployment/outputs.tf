output "deployment_name" {
  value = kubernetes_deployment.this.metadata[0].name
}

output "deployment_app_label" {
  value = kubernetes_deployment.this.spec[0].selector[0].match_labels.app
}
