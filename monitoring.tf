# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   namespace  = kubernetes_namespace.monitoring.metadata[0].name
#   chart      = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   version    = "19.0.0"
#
#   values = [
#     <<EOF
# alertmanager:
#   enabled: true
# server:
#   persistentVolume:
#     enabled: false
#   extraScrapeConfigs:
#     - job_name: 'kubernetes-cadvisor'
#       kubernetes_sd_configs:
#         - role: node
#       metrics_path: /metrics/cadvisor
#       relabel_configs:
#         - source_labels: [__meta_kubernetes_node_name]
#           target_label: node
#     - job_name: 'kubernetes-pods'
#       kubernetes_sd_configs:
#         - role: pod
#       relabel_configs:
#         - source_labels: [__meta_kubernetes_pod_name]
#           target_label: pod_name
# EOF
#   ]
# }

# resource "helm_release" "grafana" {
#   name       = "grafana"
#   namespace  = kubernetes_namespace.monitoring.metadata[0].name
#   chart      = "grafana"
#   repository = "https://grafana.github.io/helm-charts"
#   version    = "6.58.2"
#
#   values = [
#     <<EOF
# service:
#   type: NodePort
#   port: 3000
#   nodePort: 32000
# persistence:
#   enabled: false
# adminUser: "admin"
# adminPassword: "admin"
# datasources:
#   datasources.yaml:
#     apiVersion: 1
#     datasources:
#     - name: Prometheus
#       type: prometheus
#       url: http://prometheus-server.monitoring.svc.cluster.local
# EOF
#   ]
#
#   depends_on = [
#     helm_release.prometheus
#   ]
# }
