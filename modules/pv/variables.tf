variable "app_label" {
  description = "PV, PVC, and StatefulSet labels"
}

variable "pv_name" {
  type        = string
  description = "The name of the PV"
}

variable "labels" {
  type        = map(string)
  description = "Labels to attach to the PV, PVC, and StatefulSet."
  default     = {}
}

variable "pv_storage" {
  type        = string
  description = "The storage size for the PersistentVolume."
  default     = "15Gi"
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

variable "pv_storage_class" {
  type        = string
  description = "The storage class for the PersistentVolume."
  default     = "slow"
}
