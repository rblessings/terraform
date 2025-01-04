module "kubernetes_persistent_volume_claim" {
  source = "../../modules/pvc"
  labels = var.labels

  # Persistent Volume (PV) configuration
  pv_name          = format("%s-pv", var.name)
  pv_storage       = var.pv_storage
  pv_access_modes  = var.pv_access_modes
  pv_path          = var.pv_path
  pv_storage_class = var.pv_storage_class

  # Persistent Volume Claim (PVC) configuration
  pvc_namespace     = var.pvc_namespace
  pvc_storage       = var.pvc_storage
  pvc_access_modes  = var.pvc_access_modes
  pvc_storage_class = var.pvc_storage_class
  pvc_name          = format("%s-pvc", var.name)
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
        # Init container to set proper ownership and permissions on the mounted volume
        init_container {
          name    = "set-volume-permissions"
          image   = "busybox"
          command = ["/bin/sh", "-c", "chown -R 1000:1000 ${var.mount_path}"]
          volume_mount {
            mount_path = var.mount_path # Consistent path for mounting volume
            name       = "${var.name}-storage"
          }
        }

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

          # Conditionally configure liveness probe
          dynamic "liveness_probe" {
            for_each = var.liveness_probe != null ? [var.liveness_probe] : []
            content {
              # Use http_get if defined
              dynamic "http_get" {
                for_each = var.liveness_probe.http_get != null ? [var.liveness_probe.http_get] : []
                content {
                  path = http_get.value.path
                  port = http_get.value.port
                }
              }

              # Use exec if defined
              dynamic "exec" {
                for_each = var.liveness_probe.exec_command != null ? [var.liveness_probe.exec_command] : []
                content {
                  command = exec.value
                }
              }

              initial_delay_seconds = liveness_probe.value.initial_delay_seconds
              period_seconds        = liveness_probe.value.period_seconds
              timeout_seconds       = liveness_probe.value.timeout_seconds
            }
          }

          # Conditionally configure readiness probe
          dynamic "readiness_probe" {
            for_each = var.readiness_probe != null ? [var.readiness_probe] : []
            content {
              # Use http_get if defined
              dynamic "http_get" {
                for_each = var.readiness_probe.http_get != null ? [var.readiness_probe.http_get] : []
                content {
                  path = http_get.value.path
                  port = http_get.value.port
                }
              }

              # Use exec if defined
              dynamic "exec" {
                for_each = var.readiness_probe.exec_command != null ? [var.readiness_probe.exec_command] : []
                content {
                  command = exec.value
                }
              }

              initial_delay_seconds = readiness_probe.value.initial_delay_seconds
              period_seconds        = readiness_probe.value.period_seconds
              timeout_seconds       = readiness_probe.value.timeout_seconds
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
            claim_name = module.kubernetes_persistent_volume_claim.pvc_name
          }
        }
      }
    }
  }
}
