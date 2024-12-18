terraform {
  required_version = ">= 1.10.2"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }

  backend "remote" {
    organization = "rblessings-cloud-devops"
    workspaces {
      name = "terraform-project-workspace"
    }
  }
}

variable "control_plane_node_host" {
  type        = string
  default     = "https://10.38.125.65:16443"
  description = "URL of the control plane node, including protocol, IP address, and port."
}

variable "kube_config_path" {
  type        = string
  default     = "~/.kube/microk8s-config"
  description = ""
  validation {
    condition     = contains(["~/.kube/config", "~/.kube/microk8s-config"], var.kube_config_path)
    error_message = "The valid kube config path should be either '~/.kube/config' or '~/.kube/microk8s-config'."
  }
}

provider "kubernetes" {
  host        = var.control_plane_node_host
  config_path = var.kube_config_path
}

resource "kubernetes_deployment" "test" {
  metadata {
    name = "nginx"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "test" {
  metadata {
    name = "nginx"
  }
  spec {
    selector = {
      app = kubernetes_deployment.test.spec[0].template[0].metadata[0].labels.app
    }
    type = "NodePort"
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }
  }
}
