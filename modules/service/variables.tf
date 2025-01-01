variable "namespace" {
  description = "Namespace name for service"
  type = string
  default = "default"
}

variable "name" {
  description = "Name of the service"
  type        = string
}

variable "app_label" {
  description = "Label to select the deployment"
  type        = string
}

variable "service_type" {
  description = "Type of the Kubernetes service"
  type        = string
  default     = "ClusterIP"
}

variable "ports" {
  description = "List of ports for the service"
  type = list(object({
    name        = string
    port        = number
    target_port = number
  }))
}

variable "target_port" {
  description = "Port on the container that the service will forward to"
  type        = number
  default     = 80
}
