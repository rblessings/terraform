resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Creating a Persistent Volume (PV) and a Persistent Volume Claim (PVC) for Prometheus
module "kubernetes_persistent_volume_claim" {
  source = "./modules/pvc"
  labels = {}

  # Persistent Volume (PV) configuration
  pv_name          = "prometheus-alertmanager-pv"
  pv_storage       = "10Gi"
  pv_access_modes  = ["ReadWriteOnce"]
  pv_path          = "/mnt/data/prometheus-alertmanager"
  pv_storage_class = "slow"

  # Persistent Volume Claim (PVC) configuration
  pvc_name          = "storage-prometheus-alertmanager-0"
  pvc_namespace     = kubernetes_namespace.monitoring.metadata[0].name
  pvc_storage       = "10Gi"
  pvc_access_modes  = ["ReadWriteOnce"]
  pvc_storage_class = "slow"
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "26.1.0"

  # Ensure the namespace is created before the release
  depends_on = [
    kubernetes_namespace.monitoring
  ]

  # Increase Helm timeout to avoid context deadline exceeded errors
  timeout = 600 # 10 minutes

  values = [
    <<EOF
alertmanager:
  enabled: true

server:
  service:
    type: NodePort
    port: 9090
    nodePort: 32002

  persistentVolume:
    enabled: false

  extraScrapeConfigs:
    - job_name: 'kubernetes-cadvisor'
      kubernetes_sd_configs:
        - role: node
      metrics_path: /metrics/cadvisor
      relabel_configs:
        - source_labels: [__meta_kubernetes_node_name]
          target_label: node

    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        - source_labels: [__meta_kubernetes_pod_name]
          target_label: pod_name
EOF
  ]
}

# TODO: Parameterize Grafana credentials (adminUser and adminPassword) and store them securely
#  in HashiCorp Vault or Kubernetes Secrets.
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
