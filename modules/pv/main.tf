# TODO: We're currently using HostPath volumes, which work for single-node setups but limit scaling across multiple nodes.
#       Transition to a more scalable solution (e.g., network-attached storage or cloud volumes) for production.
#       See issue #36 for alternatives: https://github.com/rblessings/terraform/issues/36.

resource "kubernetes_persistent_volume" "this" {
  metadata {
    name = var.pv_name
    labels = merge(var.labels, {
      app  = var.app_label, # Ensure this matches the StatefulSet labels
      type = "hostpath"     # Label to ensure PVC binds to the correct PV
    })
  }

  spec {
    capacity = {
      storage = var.pv_storage
    }

    access_modes = var.pv_access_modes

    persistent_volume_source {
      host_path {
        path = var.pv_path # Ensure this path exists on the node
      }
    }

    storage_class_name = var.pv_storage_class
  }
}
