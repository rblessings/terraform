resource "kubernetes_service" "this" {
  metadata {
    namespace = var.namespace
    name = var.name
  }

  spec {
    selector = {
      app = var.app_label
    }

    type = var.service_type

    port {
      port        = var.port
      target_port = var.target_port
    }
  }
}
