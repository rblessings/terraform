resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# TODO: Review and implement the following before production:
#   - Ensure the Prometheus service type is appropriately configured (e.g., ClusterIP for internal access or LoadBalancer for external access).
#   - Set resource requests and limits for CPU and memory to ensure proper resource allocation in production environments.
#   - Ensure alerting rules and scrape configurations are aligned with production monitoring needs.
#   - Review the persistent storage configuration for Prometheus (consider enabling PV for Prometheus server if persistent data retention is required).
#   - Implement proper security settings such as enabling TLS for communication and restricting access to the Prometheus dashboard.

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "26.1.0"

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_persistent_volume_claim.prometheus_alertmanager
  ]

  timeout = 600 # Extend the Helm timeout to 10 minutes to prevent 'context deadline exceeded' errors.

  values = [
    <<EOF
alertmanager:
  persistentVolume:
    enabled: true

server:
  persistentVolume:
    enabled: false

  service:
    type: NodePort
    port: 9090
    nodePort: 32002

extraScrapeConfigs: |
  - job_name: 'urlradar-metrics'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['urlradar-svc.default.svc.cluster.local:8080']
EOF
  ]
}

# TODO: Review and implement the following before production:
#   - Configure persistent storage for Grafana to ensure data retention between restarts.
#   - Set resource requests and limits for CPU and memory to ensure efficient resource management in production.
#   - Secure Grafana admin credentials by using Kubernetes secrets or external vault solutions instead of hardcoding them in values.yaml.
#   - Review and update the service type (consider ClusterIP or LoadBalancer depending on internal or external access requirements).
#   - Enable authentication and authorization mechanisms (e.g., OAuth, LDAP) for securing Grafana dashboards.

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = "8.8.2"

  depends_on = [
    helm_release.prometheus
  ]

  values = [
    <<EOF
service:
  type: NodePort
  port: 3000
  nodePort: 32000

persistence:
  enabled: false

adminUser: "admin"
adminPassword: "admin"

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.monitoring.svc.cluster.local
EOF
  ]
}

# TODO: The StatefulSet is currently using HostPath volumes for persistent storage.
#       While functional for single-node deployments, this setup limits scalability and prevents horizontal scaling across multiple nodes.
#       Consider transitioning to a more scalable solution (e.g., network-attached storage or cloud volumes).
#       For alternatives and further discussion, refer to issue #36 at https://github.com/rblessings/terraform/issues/36.

# Definition of the Persistent Volume (PV) for Prometheus Alertmanager
module "kubernetes_persistent_volume" {
  source = "./modules/pv"

  labels = {
    app  = "prometheus",
    type = "hostpath"
  }
  app_label = "prometheus"

  # Configuration details for the Persistent Volume (PV)
  pv_name          = "prometheus-alertmanager-pv"
  pv_storage       = "10Gi"
  pv_access_modes  = ["ReadWriteOnce"]
  pv_path          = "/mnt/data/prometheus-alertmanager"
  pv_storage_class = "manual"
}

# Persistent Volume Claim (PVC) configuration for Prometheus Alertmanager
resource "kubernetes_persistent_volume_claim" "prometheus_alertmanager" {
  metadata {
    name      = "storage-prometheus-alertmanager-0"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      app = "prometheus"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"] # Access mode must align with the corresponding PV configuration

    resources {
      requests = {
        storage = "10Gi" # Request must be less than or equal to the PV storage capacity
      }
    }

    storage_class_name = "manual"                     # Storage class should match the Persistent Volume
    volume_name        = "prometheus-alertmanager-pv" # Volume name must be consistent with the PV name
  }
}
