resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

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

  depends_on = [
    kubernetes_namespace.monitoring
  ]

  timeout = 600 # Increase Helm timeout to 10 minutes to avoid context deadline exceeded errors.

  values = [
    <<EOF
alertmanager:
  enabled: true

server:
  persistentVolume:
    enabled: false

extraScrapeConfigs: |
  - job_name: 'urlradar-metrics'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['urlradar-svc.default.svc.cluster.local:8080']
EOF
  ]
}

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
