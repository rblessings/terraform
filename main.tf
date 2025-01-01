provider "kubernetes" {
  host        = trimspace(var.control_plane_node_host)
  config_path = trimspace(var.kube_config_path)
}

provider "helm" {
  kubernetes {
    host        = trimspace(var.control_plane_node_host)
    config_path = trimspace(var.kube_config_path)
  }
}

# module "urlradar_deployment" {
#   source         = "./modules/deployment"
#   name           = "urlradar"
#   app_label      = "urlradar"
#   image          = "rblessings/urlradar:latest"
#   container_name = "urlradar"
#   replicas       = 3
#   container_port = 80
#
#   # Increase memory limit and request to 1GB
#   memory_limit   = "1Gi" # Set memory limit to 1 GB
#   memory_request = "1Gi" # Set memory request to 1 GB
#
#   # Set CPU limits and requests
#   cpu_request = "250m" # 250m CPU (quarter of one CPU core)
#   cpu_limit   = "4"    # 4 CPU cores (unrealistically high, but practically unlimited)
#
#   # Health checks
#   liveness_probe_path             = "/"
#   liveness_initial_delay_seconds  = 10
#   liveness_period_seconds         = 5
#   readiness_probe_path            = "/"
#   readiness_initial_delay_seconds = 5
#   readiness_period_seconds        = 5
#
#   # TODO connect to kubernetes services for each respective service
#   # Adding environment variables for dependencies (MongoDB, Redis, Elasticsearch, Kafka)
#   environment = [
#     {
#       name  = "MONGO_URL"
#       value = "mongodb://root:secret@mongodb:27017/urlradar"
#     },
#     {
#       name  = "REDIS_URL"
#       value = "redis://redis:6379"
#     },
#     {
#       name  = "ELASTICSEARCH_URL"
#       value = "http://elasticsearch:9200"
#     },
#     {
#       name  = "KAFKA_BROKER_URL"
#       value = "PLAINTEXT://kafka:9092"
#     }
#   ]
#
#   depends_on = [
#     module.elasticsearch_deployment,
#     module.mongodb_deployment,
#     module.redis_deployment,
#     module.kafka_deployment,
#   ]
# }

# module "urlradar_service" {
#   source      = "./modules/service"
#   name        = "urlradar"
#   app_label   = module.urlradar_deployment.deployment_app_label
#   port        = 80
#   target_port = 80
#
#   depends_on = [
#     module.urlradar_deployment
#   ]
# }

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

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

# ---

# module "elasticsearch_deployment" {
#   source         = "./modules/deployment"
#   name           = "elasticsearch"
#   app_label      = "elasticsearch"
#   image          = "docker.elastic.co/elasticsearch/elasticsearch:8.17.0"
#   container_name = "elasticsearch"
#   replicas       = 1
#   container_port = 9200
#
#   memory_limit   = "2Gi"
#   memory_request = "1Gi"
#   cpu_request    = "500m"
#   cpu_limit      = "1"
#
#   # Health checks
#   liveness_probe_path             = "/"
#   liveness_initial_delay_seconds  = 10
#   liveness_period_seconds         = 5
#   readiness_probe_path            = "/"
#   readiness_initial_delay_seconds = 5
#   readiness_period_seconds        = 5
#
#   # Pass Elasticsearch-specific environment variables
#   environment = [
#     {
#       name  = "ELASTIC_PASSWORD"
#       value = "secret" # TODO Use a more secure method (e.g., Kubernetes Secrets)
#     },
#     {
#       name  = "discovery.type"
#       value = "single-node"
#     },
#     {
#       name  = "xpack.security.enabled"
#       value = "false"
#     }
#   ]
# }

# module "elasticsearch_service" {
#   source      = "./modules/service"
#   name        = "elasticsearch"
#   app_label   = module.elasticsearch_deployment.deployment_app_label
#   port        = 9200
#   target_port = 9200
#
#   depends_on = [
#     module.elasticsearch_deployment
#   ]
# }

# ---

# module "kafka_deployment" {
#   source         = "./modules/deployment"
#   name           = "kafka"
#   app_label      = "kafka"
#   image          = "apache/kafka:3.9.0"
#   container_name = "kafka"
#   replicas       = 1
#   container_port = 9092
#
#   memory_limit   = "2Gi"
#   memory_request = "1Gi"
#   cpu_request    = "500m"
#   cpu_limit      = "1"
#
#   # Health checks
#   liveness_probe_path             = "/"
#   liveness_initial_delay_seconds  = 10
#   liveness_period_seconds         = 5
#   readiness_probe_path            = "/"
#   readiness_initial_delay_seconds = 5
#   readiness_period_seconds        = 5
#
#   environment = [
#     {
#       name  = "KAFKA_PROCESS_ROLES"
#       value = "broker,controller"
#     },
#     {
#       name  = "KAFKA_NODE_ID"
#       value = "1"
#     },
#     {
#       name  = "KAFKA_CONTROLLER_QUORUM_VOTERS"
#       value = "1@localhost:9093"
#     },
#     {
#       name  = "KAFKA_LISTENERS"
#       value = "PLAINTEXT://:9092,CONTROLLER://:9093"
#     },
#     {
#       name  = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
#       value = "PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT"
#     },
#     {
#       name  = "KAFKA_INTER_BROKER_LISTENER_NAME"
#       value = "PLAINTEXT"
#     },
#     {
#       name  = "KAFKA_ADVERTISED_LISTENERS"
#       value = "PLAINTEXT://localhost:9092"
#     },
#     {
#       name  = "KAFKA_CONTROLLER_LISTENER_NAMES"
#       value = "CONTROLLER"
#     }
#   ]
# }

# module "kafka_service" {
#   source      = "./modules/service"
#   name        = "kafka"
#   app_label   = module.kafka_deployment.deployment_app_label
#   port        = 9092
#   target_port = 9092
#
#   depends_on = [
#     module.kafka_deployment
#   ]
# }

# --

# module "mongodb_deployment" {
#   source         = "./modules/deployment"
#   name           = "mongodb"
#   app_label      = "mongodb"
#   image          = "mongo:latest"
#   container_name = "mongodb"
#   replicas       = 1
#   container_port = 27017
#
#   memory_limit   = "2Gi"
#   memory_request = "1Gi"
#   cpu_request    = "500m"
#   cpu_limit      = "1"
#
#   # Health checks
#   liveness_probe_path             = "/"
#   liveness_initial_delay_seconds  = 10
#   liveness_period_seconds         = 5
#   readiness_probe_path            = "/"
#   readiness_initial_delay_seconds = 5
#   readiness_period_seconds        = 5
#
#   # MongoDB-specific environment variables
#   environment = [
#     {
#       name  = "MONGO_INITDB_ROOT_USERNAME"
#       value = "root"
#     },
#     {
#       name  = "MONGO_INITDB_ROOT_PASSWORD"
#       value = "secret" # TODO Use a more secure method (e.g., Kubernetes Secrets)
#     },
#     {
#       name  = "MONGO_INITDB_DATABASE"
#       value = "urlradar"
#     }
#   ]
# }

# module "mongodb_service" {
#   source      = "./modules/service"
#   name        = "mongodb"
#   app_label   = module.mongodb_deployment.deployment_app_label
#   port        = 27017
#   target_port = 27017
#
#   depends_on = [
#     module.mongodb_deployment
#   ]
# }

# ---

# module "redis_deployment" {
#   source         = "./modules/deployment"
#   name           = "redis"
#   app_label      = "redis"
#   image          = "redis:latest"
#   container_name = "redis"
#   replicas       = 1
#   container_port = 6379
#
#   memory_limit   = "512Mi"
#   memory_request = "256Mi"
#   cpu_request    = "200m"
#   cpu_limit      = "500m"
#
#   # Health checks
#   liveness_probe_path             = "/"
#   liveness_initial_delay_seconds  = 10
#   liveness_period_seconds         = 5
#   readiness_probe_path            = "/"
#   readiness_initial_delay_seconds = 5
#   readiness_period_seconds        = 5
#
#   # Redis-specific environment variables (e.g., for password, etc.)
#   environment = [
#     {
#       name  = "REDIS_PASSWORD"
#       value = "secret" # TODO Use a more secure method (e.g., Kubernetes Secrets)
#     }
#   ]
# }

# module "redis_service" {
#   source      = "./modules/service"
#   name        = "redis"
#   app_label   = module.redis_deployment.deployment_app_label
#   port        = 6379
#   target_port = 6379
#
#   depends_on = [
#     module.redis_deployment
#   ]
# }


# ---
# output "urlradar_deployment_name" {
#   value = module.urlradar_deployment.deployment_name
# }

# output "urlradar_service_name" {
#   value = module.urlradar_service.service_name
# }

# output "grafana_url" {
#   value       = "http://<node-ip>:32000" # Control plane node IP
#   description = "Access Grafana using this URL"
# }

# output "prometheus_url" {
#   value       = "http://prometheus-server.monitoring.svc.cluster.local"
#   description = "Prometheus endpoint in the cluster"
# }
