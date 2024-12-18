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
  description = "URL of the control plane node, including protocol, IP address, and optional port."

  # Validation to ensure the control_plane_node_host matches the required URL format:
  # - The URL must start with 'https://'.
  # - It can be either:
  #   - A valid IPv4 address (e.g., 192.168.1.1), or
  #   - A valid domain name (e.g., example.com).
  # - Optionally, it may include a port number (1-65535).
  validation {
    condition = can(
      regex("^https:\\/\\/((?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}|(?:[0-9]{1,3}\\.){3}[0-9]{1,3})(?::[0-9]{1,5})?$",
      var.control_plane_node_host)
    )
    error_message = "The control_plane_node_host must be in the format https://<IP_ADDRESS|DOMAIN_NAME>:<PORT>"
  }
}

variable "kube_config_path" {
  type        = string
  default     = "~/.kube/microk8s-config"
  description = "Path to the Kubernetes config file used for authentication and cluster access."

  validation {
    condition     = fileexists(var.kube_config_path)
    error_message = "The file at kube_config_path does not exist. Please provide a valid Kubernetes config path."
  }
}

provider "kubernetes" {
  host        = trimspace(var.control_plane_node_host)
  config_path = trimspace(var.kube_config_path)
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
