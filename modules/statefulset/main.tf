resource "kubernetes_persistent_volume" "this" {
  metadata {
    name = "${var.name}-pv"
    labels = merge(var.labels, {
      type = "hostpath"
    })
  }

  spec {
    capacity = {
      storage = var.pv_storage
    }

    access_modes = var.pv_access_modes

    persistent_volume_source {
      host_path {
        path = var.pv_path
      }
    }

    storage_class_name = var.pv_storage_class
  }
}

resource "kubernetes_persistent_volume_claim" "this" {
  metadata {
    name = "${var.name}-pvc"
  }

  spec {
    resources {
      requests = {
        storage = var.pvc_storage
      }
    }

    access_modes = var.pvc_access_modes

    selector {
      match_labels = merge(var.labels, {
        type = "hostpath"
      })
    }

    storage_class_name = var.pvc_storage_class
  }
}

resource "kubernetes_stateful_set" "this" {
  metadata {
    name = var.name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = merge(var.labels, {
        app = var.app_label
      })
    }

    service_name = var.name

    template {
      metadata {
        labels = merge(var.labels, {
          app = var.app_label
        })
      }

      spec {
        container {
          name  = var.container_name
          image = var.image

          port {
            container_port = var.container_port
          }

          resources {
            limits   = var.resource_limits
            requests = var.resource_requests
          }

          # Liveness Probe (if provided)
          dynamic "liveness_probe" {
            for_each = var.liveness_probe != null ? [var.liveness_probe] : []
            content {
              exec {
                command = liveness_probe.value.exec_command
              }
              initial_delay_seconds = liveness_probe.value.initial_delay_seconds
              period_seconds        = liveness_probe.value.period_seconds
            }
          }

          # Readiness Probe (if provided)
          dynamic "readiness_probe" {
            for_each = var.readiness_probe != null ? [var.readiness_probe] : []
            content {
              exec {
                command = readiness_probe.value.exec_command
              }
              initial_delay_seconds = readiness_probe.value.initial_delay_seconds
              period_seconds        = readiness_probe.value.period_seconds
            }
          }

          # Environment Variables
          dynamic "env" {
            for_each = var.environment != null ? var.environment : []
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          # Mount the persistent volume
          volume_mount {
            mount_path = var.mount_path
            name       = "${var.name}-storage"
          }
        }

        # Define volume and link to PVC
        volume {
          name = "${var.name}-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.this.metadata[0].name
          }
        }
      }
    }
  }
}
