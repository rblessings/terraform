output "pv_name" {
  value = kubernetes_persistent_volume.this.metadata[0].name
}
