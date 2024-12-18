variable "control_plane_node_host" {
  type        = string
  default     = "https://10.38.125.65:16443"
  description = "URL of the control plane node, including protocol, IP address, and optional port."

  # Validation to ensure control_plane_node_host matches the URL format:
  # - It must start with 'https://'.
  # - It can be either an IPv4 address (e.g., 192.168.1.1),
  #   or a domain name, optionally followed by a port (1-65535).
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