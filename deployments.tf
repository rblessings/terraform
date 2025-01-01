module "urlradar_deployment" {
  source         = "./modules/deployment"
  name           = "urlradar"
  app_label      = "urlradar"
  image          = "rblessings/urlradar:c4c4238c831534637a25ccd65938a1503d828069"
  container_name = "urlradar"

  # TODO At the moment, URLradar is not stateless compliant (see README.md for details and progress).
  #  This limits demos to one pod.
  replicas       = 1
  container_port = 8080

  # Increase memory limit and request to 1GB
  memory_limit   = "1Gi" # Set memory limit to 1 GB
  memory_request = "1Gi" # Set memory request to 1 GB

  # Set CPU limits and requests
  cpu_request = "250m" # 250m CPU (quarter of one CPU core)
  cpu_limit   = "4"    # 4 CPU cores (unrealistically high, but practically unlimited)

  # Health checks
  # liveness_probe_path             = "/actuator/health"
  # liveness_initial_delay_seconds  = 60
  # liveness_period_seconds         = 15
  # readiness_probe_path            = "/actuator/health"
  # readiness_initial_delay_seconds = 60
  # readiness_period_seconds        = 15

  # Adding environment variables for dependencies (MongoDB, Redis, Elasticsearch, Kafka)
  environment = [
    {
      name  = "MONGO_URL"
      value = "mongodb://root:secret@mongodb-svc:27017/urlradar"
    }/*,
    {
      name  = "REDIS_URL"
      value = "redis://redis:6379"
    },
    {
      name  = "ELASTICSEARCH_URL"
      value = "http://elasticsearch:9200"
    },
    {
      name  = "KAFKA_BROKER_URL"
      value = "PLAINTEXT://kafka:9092"
    }*/
  ]

  depends_on = [
    # module.elasticsearch_deployment,
    module.mongodb_statefulset,
    # module.redis_deployment,
    # module.kafka_deployment,
  ]
}

module "mongodb_statefulset" {
  source         = "./modules/statefulset"
  name           = "mongodb"
  app_label      = "mongodb"
  image          = "mongo:latest"
  container_name = "mongodb"
  replicas       = 3
  container_port = 27017

  resource_limits = {
    cpu    = "1"
    memory = "2Gi"
  }

  resource_requests = {
    cpu    = "500m"
    memory = "1Gi"
  }

  # Health checks
  # liveness_probe = {
  #   exec_command          = ["mongosh", "--eval", "db.adminCommand('ping').ok"]
  #   initial_delay_seconds = 60
  #   period_seconds        = 15
  # }
  #
  # readiness_probe = {
  #   exec_command          = ["mongosh", "--eval", "db.adminCommand('ping').ok"]
  #   initial_delay_seconds = 60
  #   period_seconds        = 15
  # }

  environment = [
    {
      name  = "MONGO_INITDB_ROOT_USERNAME"
      value = "root"
    },
    {
      name  = "MONGO_INITDB_ROOT_PASSWORD"
      value = "secret"
    },
    {
      name  = "MONGO_INITDB_DATABASE"
      value = "urlradar"
    }
  ]

  labels = {
    env = "dev"
  }

  pv_storage = "20Gi"
  pvc_storage = "10Gi"
  mount_path = "/data/db"
}
