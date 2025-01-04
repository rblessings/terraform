variable "name" {
  description = "Name of the deployment"
  type        = string
}

variable "app_label" {
  description = "App label for deployment"
  type        = string
}

variable "image" {
  description = "Container image to deploy"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "cpu_limit" {
  description = "Maximum CPU allocated to the container"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Maximum memory allocated to the container"
  type        = string
  default     = "512Mi"
}

variable "cpu_request" {
  description = "CPU requested by the container"
  type        = string
  default     = "250m"
}

variable "memory_request" {
  description = "Memory requested by the container"
  type        = string
  default     = "256Mi"
}

variable "liveness_probe" {
  description = "Liveness probe configuration."
  type = object({
    exec_command          = optional(list(string))
    initial_delay_seconds = number
    period_seconds        = number
    http_get = optional(object({
      path = string
      port = number
    }))
  })
  default = null
}

variable "readiness_probe" {
  description = "Readiness probe configuration."
  type = object({
    exec_command          = optional(list(string))
    initial_delay_seconds = number
    period_seconds        = number
    http_get = optional(object({
      path = string
      port = number
    }))
  })
  default = null
}

variable "environment" {
  description = "List of environment variables for the deployment"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
