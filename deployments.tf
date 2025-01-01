module "urlradar_deployment" {
  source         = "./modules/deployment"
  name           = "urlradar"
  app_label      = "urlradar"
  image          = "rblessings/urlradar:latest"
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

  environment = [
    {
      name  = "SPRING_DATA_MONGODB_URI"
      value = "mongodb://root:secret@mongodb-svc:27017/urlradar?authSource=admin"
    },
    {
      name  = "SPRING_DATA_REDIS_HOST"
      value = "redis-svc"
    },
    {
      name  = "SPRING_DATA_REDIS_PORT"
      value = "6379"
    },
    {
      name  = "SPRING_KAFKA_BOOTSTRAP_SERVERS"
      value = "kafka-svc:9092"
    },
    {
      name  = "SPRING_ELASTICSEARCH_URIS"
      value = "http://elasticsearch-svc:9200"
    },
    {
      name  = "SPRING_ELASTICSEARCH_PASSWORD"
      value = "secret"
    }
  ]

  depends_on = [
    module.mongodb_statefulset,
    module.redis_statefulset,
    module.kafka_statefulset,
    module.elasticsearch_statefulset,
  ]
}

module "mongodb_statefulset" {
  source         = "./modules/statefulset"
  name           = "mongodb"
  app_label      = "mongodb"
  image          = "mongo:latest"
  container_name = "mongodb"
  replicas       = 1
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
      value = "secret" # TODO: Store Secret in Secure Vault or Kubernetes Secret
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

module "redis_statefulset" {
  source         = "./modules/statefulset"
  name           = "redis"
  app_label      = "redis"
  image          = "redis:latest"
  container_name = "redis"
  replicas       = 1
  container_port = 6379

  resource_limits = {
    cpu    = "500m"
    memory = "1Gi"
  }

  resource_requests = {
    cpu    = "250m"
    memory = "512Mi"
  }

  environment = []

  labels = {
    env = "dev"
  }

  pv_storage = "5Gi"
  pvc_storage = "2Gi"
  mount_path = "/data"
}

module "kafka_statefulset" {
  source         = "./modules/statefulset"
  name           = "kafka"
  app_label      = "kafka"
  image          = "apache/kafka:3.9.0"
  container_name = "kafka"
  replicas       = 1
  container_port = 9092

  resource_limits = {
    cpu    = "1"
    memory = "2Gi"
  }

  resource_requests = {
    cpu    = "500m"
    memory = "1Gi"
  }

  environment = [
    {
      name  = "KAFKA_PROCESS_ROLES"
      value = "broker,controller"
    },
    {
      name  = "KAFKA_NODE_ID"
      value = "1"
    },
    {
      name  = "KAFKA_CONTROLLER_QUORUM_VOTERS"
      value = "1@localhost:9093"
    },
    {
      name  = "KAFKA_LISTENERS"
      value = "PLAINTEXT://:9092,CONTROLLER://:9093"
    },
    {
      name  = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
      value = "PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT"
    },
    {
      name  = "KAFKA_INTER_BROKER_LISTENER_NAME"
      value = "PLAINTEXT"
    },
    {
      name  = "KAFKA_ADVERTISED_LISTENERS"
      value = "PLAINTEXT://localhost:9092"
    },
    {
      name  = "KAFKA_CONTROLLER_LISTENER_NAMES"
      value = "CONTROLLER"
    },
    {
      name  = "KAFKA_AUTO_CREATE_TOPICS_ENABLE"
      value = "true"
    },
    {
      name  = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
      value = "1"
    },
    {
      name  = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
      value = "1"
    },
    {
      name  = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
      value = "1"
    },
    {
      name  = "KAFKA_LOG_DIRS"
      value = "/var/lib/kafka/data"
    },
    {
      name  = "KAFKA_CLUSTER_ID"
      value = "urlradar-27-12-2024"
    }
  ]

  labels = {
    env = "dev"
  }

  pv_storage = "20Gi"
  pvc_storage = "10Gi"
  # mount_path = "/var/lib/kafka/data"
}

module "elasticsearch_statefulset" {
  source         = "./modules/statefulset"
  name           = "elasticsearch"
  app_label      = "elasticsearch"
  image          = "docker.elastic.co/elasticsearch/elasticsearch:8.17.0"
  container_name = "elasticsearch"
  replicas       = 1
  container_port = 9200

  resource_limits = {
    cpu    = "1"
    memory = "2Gi"
  }

  resource_requests = {
    cpu    = "500m"
    memory = "1Gi"
  }

  environment = [
    {
      name  = "ELASTIC_PASSWORD"
      value = "secret" # TODO: Store Secret in Secure Vault or Kubernetes Secret
    },
    {
      name  = "discovery.type"
      value = "single-node"
    },
    {
      name  = "xpack.security.enabled"
      value = "false"
    }
  ]

  labels = {
    env = "dev"
  }

  pv_storage = "20Gi"
  pvc_storage = "10Gi"
  # mount_path = "/usr/share/elasticsearch/data"
}
