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
  default     = "NodePort"
}

variable "port" {
  description = "Port of the service"
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Port on the container that the service will forward to"
  type        = number
  default     = 80
}
