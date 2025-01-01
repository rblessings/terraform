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
  default     = 80
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

# variable "liveness_probe_path" {
#   description = "Path to check for liveness probe"
#   type        = string
#   default     = "/"
# }
#
# variable "liveness_initial_delay_seconds" {
#   description = "Initial delay for liveness probe"
#   type        = number
#   default     = 10
# }
#
# variable "liveness_period_seconds" {
#   description = "Period for liveness probe checks"
#   type        = number
#   default     = 5
# }
#
# variable "readiness_probe_path" {
#   description = "Path to check for readiness probe"
#   type        = string
#   default     = "/"
# }
#
# variable "readiness_initial_delay_seconds" {
#   description = "Initial delay for readiness probe"
#   type        = number
#   default     = 5
# }
#
# variable "readiness_period_seconds" {
#   description = "Period for readiness probe checks"
#   type        = number
#   default     = 5
# }

variable "environment" {
  description = "List of environment variables for the deployment"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
