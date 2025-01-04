/*
  This resource definition demonstrates one method for deploying a workload on a Kubernetes cluster
  using the Terraform Kubernetes provider.

  While this approach works well for simple workloads, it is generally recommended to use pre-existing
  Kubernetes YAML manifests for more complex or production-grade applications. These manifests are often
  created and maintained by infrastructure teams to ensure consistency and alignment with best practices.

  Example of using a Kubernetes manifest resource:

  provider "kubernetes" {
    // Configure the Kubernetes provider with the necessary credentials and cluster details
  }

  resource "kubernetes_manifest" "example" {
    provider = kubernetes
    manifest = yamldecode(file("${path.module}/deployment.yaml"))
  }

  This approach allows you to directly apply Kubernetes YAML configuration files, which is particularly
  useful in environments where manifests are already in use, need to be version-controlled, or must be
  maintained separately from Terraform configuration.
*/

resource "kubernetes_deployment" "this" {
  metadata {
    name = var.name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_label
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_label
        }
      }

      spec {
        container {
          image = var.image
          name  = var.container_name

          port {
            container_port = var.container_port
          }

          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
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
              timeout_seconds       = 3
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
              timeout_seconds       = 3
            }
          }

          # Dynamic environment variables section
          dynamic "env" {
            for_each = var.environment != null ? var.environment : []

            content {
              name  = env.value.name
              value = env.value.value
            }
          }
        }
      }
    }
  }
}


