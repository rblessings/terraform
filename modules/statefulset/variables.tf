variable "name" {
  type        = string
  description = "The name of the StatefulSet."
}

variable "labels" {
  type        = map(string)
  description = "Labels to attach to the PV, PVC, and StatefulSet."
  default     = {}
}

variable "replicas" {
  type        = number
  description = "The number of replicas in the StatefulSet."
  default     = 1
}

variable "app_label" {
  type        = string
  description = "The label for the app."
}

variable "container_name" {
  type        = string
  description = "The container name."
}

variable "image" {
  type        = string
  description = "The Docker image for the container."
}

variable "container_port" {
  type        = number
  description = "The container port to expose."
}

variable "resource_limits" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "The resource limits (e.g., cpu, memory)."
}

variable "resource_requests" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "The resource requests (e.g., cpu, memory)."
}

variable "liveness_probe" {
  description = "Liveness probe configuration."
  type = object({
    exec_command          = optional(list(string))
    initial_delay_seconds = number
    period_seconds        = number
    timeout_seconds       = number
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
    timeout_seconds       = number
    http_get = optional(object({
      path = string
      port = number
    }))
  })
  default = null
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment variables for the container."
  default     = []
}

variable "mount_path" {
  type        = string
  description = "The path inside the container where the volume will be mounted."
}

variable "pv_storage_class" {
  type        = string
  description = "The storage class for the PersistentVolume."
  default     = "slow"
}

variable "pv_storage" {
  type        = string
  description = "The storage size for the PersistentVolume."
  default     = "10Gi"
}

variable "pv_access_modes" {
  type        = list(string)
  description = "The access modes for the PersistentVolume."
  default     = ["ReadWriteOnce"]
}

# corresponds to a directory on the node where data will persist
variable "pv_path" {
  type        = string
  description = "The host path for the PersistentVolume."
}
