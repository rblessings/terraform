resource "kubernetes_service" "this" {
  metadata {
    namespace = var.namespace
    name      = var.name
  }

  spec {
    selector = {
      app = var.app_label
    }

    type = var.service_type

    dynamic "port" {
      for_each = var.ports
      content {
        name        = port.value.name
        port        = port.value.port
        target_port = port.value.target_port
      }
    }
  }
}
