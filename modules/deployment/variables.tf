variable "name" {
  description = "Name of the deployment"
  type        = string
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 3
}

variable "app_label" {
  description = "Label to identify the application"
  type        = string
}

variable "image" {
  description = "Docker image to use for the container"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}
