/*
  This resource definition demonstrates one approach for deploying a workload on a Kubernetes cluster
  using the Terraform Kubernetes provider.

  While this method is suitable for simple workloads, for more complex or production-grade applications,
  it is often preferable to leverage pre-existing YAML manifests. These manifests are typically created
  and maintained by infrastructure teams, ensuring consistency and alignment with best practices.

  Example of using a Kubernetes manifest resource:

  provider "kubernetes" {
    // Configure the Kubernetes provider with appropriate credentials and cluster details
  }

  resource "kubernetes_manifest" "example" {
    provider = kubernetes
    manifest = yamldecode(file("${path.module}/deployment.yaml"))
  }

  This approach allows for the direct application of YAML configuration files, which may be beneficial
  in environments where Kubernetes manifests are already in use or need to be version-controlled.
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

          liveness_probe {
            http_get {
              path = var.liveness_probe_path
              port = var.container_port
            }
            initial_delay_seconds = var.liveness_initial_delay_seconds
            period_seconds        = var.liveness_period_seconds
          }

          readiness_probe {
            http_get {
              path = var.readiness_probe_path
              port = var.container_port
            }
            initial_delay_seconds = var.readiness_initial_delay_seconds
            period_seconds        = var.readiness_period_seconds
          }
        }
      }
    }
  }
}


