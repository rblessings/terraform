# TODO: The StatefulSet is currently using HostPath volumes for persistent storage.
#   While this setup works for single-node deployments, it severely limits our ability to scale horizontally across multiple nodes.
#   For upcoming alternatives, refer to issue #36 at https://github.com/rblessings/terraform/issues/36
resource "kubernetes_persistent_volume" "this" {
  metadata {
    name = var.pv_name
    labels = merge(var.labels, {
      type = "hostpath" # Label to ensure PVC binds to the correct PV
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

resource "kubernetes_persistent_volume_claim" "this" {
  metadata {
    name      = var.pvc_name
    namespace = var.pvc_namespace
  }

  spec {
    resources {
      requests = {
        storage = var.pvc_storage
      }
    }

    access_modes       = var.pvc_access_modes
    storage_class_name = var.pvc_storage_class
    volume_name        = kubernetes_persistent_volume.this.metadata[0].name
  }
}