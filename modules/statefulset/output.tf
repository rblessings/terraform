output "statefulset_name" {
  description = "The name of the StatefulSet"
  value       = kubernetes_stateful_set.this.metadata[0].name
}