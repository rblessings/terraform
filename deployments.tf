module "urlradar_deployment" {
  source         = "./modules/deployment"
  name           = "urlradar"
  app_label      = "urlradar"
  image          = "rblessings/urlradar:latest"
  container_name = "urlradar"

  # TODO: URLradar is not yet stateless-compliant. Refer to the URLradar project README.md for ongoing work in this area.
  #   This constraint restricts testing to a single pod configuration.
  replicas       = 1
  container_port = 8080

  cpu_request = "0.5"
  cpu_limit   = "2"

  memory_request = "1Gi"
  memory_limit   = "2Gi"

  # Health checks for liveness and readiness probes monitor the application's health
  # and ensure that dependencies (e.g., MongoDB, Kafka, Redis) are available.
  liveness_probe = {
    initial_delay_seconds = 90
    period_seconds        = 30
    http_get = {
      path = "/actuator/health"
      port = 8080
    }
  }

  readiness_probe = {
    initial_delay_seconds = 90
    period_seconds        = 30
    http_get = {
      path = "/actuator/health"
      port = 8080
    }
  }

  environment = [
    {
      name = "SPRING_DATA_MONGODB_URI"

      # TODO: Integrate HashiCorp Vault or Kubernetes Secrets for secure credential retrieval.
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
    }
  ]

  depends_on = [
    module.mongodb_statefulset,
    module.redis_statefulset,
    module.kafka_statefulset
  ]
}

module "mongodb_statefulset" {
  source         = "./modules/statefulset"
  name           = "mongodb"
  app_label      = "mongodb"
  image          = "mongo:8.0.4"
  container_name = "mongodb"
  replicas       = 1
  container_port = 27017

  resource_requests = {
    cpu    = "2"        # Request 2 CPU cores (minimum required for MongoDB)
    memory = "4Gi"      # Request 4Gi of memory (enough for moderate workloads)
  }

  resource_limits = {
    cpu    = "4"        # Limit to 4 CPU cores (to avoid overloading the node)
    memory = "8Gi"      # Set a higher memory limit (e.g., 8Gi) for better scalability
  }

  # Health checks for MongoDB: Liveness and readiness probes ensure
  # MongoDB is operational and responsive.
  liveness_probe = {
    initial_delay_seconds = 120
    period_seconds        = 30
    timeout_seconds       = 3
    exec_command = [
      "mongosh", "--eval", "db.adminCommand('ping').ok"
    ]
  }

  readiness_probe = {
    initial_delay_seconds = 120
    period_seconds        = 30
    timeout_seconds       = 3
    exec_command = [
      "mongosh", "--eval", "db.adminCommand('ping').ok"
    ]
  }

  environment = [
    {
      name  = "MONGO_INITDB_ROOT_USERNAME"
      value = "root"
    },
    {
      name  = "MONGO_INITDB_ROOT_PASSWORD"
      value = "secret" # TODO: Integrate HashiCorp Vault or Kubernetes Secrets for secure credential retrieval.
    },
    {
      name  = "MONGO_INITDB_DATABASE"
      value = "urlradar"
    }
  ]

  labels = {
    env = "dev"
  }

  mount_path  = "/data/db"
  pv_path     = "/mnt/data/mongodb-logs"
  pv_storage  = "20Gi"
  pvc_storage = "10Gi"
}

module "kafka_statefulset" {
  source         = "./modules/statefulset"
  name           = "kafka"
  app_label      = "kafka"
  image          = "apache/kafka:3.9.0"
  container_name = "kafka"
  replicas       = 1
  container_port = 9092

  resource_requests = {
    cpu    = "2"         # Request 2 CPU cores (minimum for moderate workloads)
    memory = "4Gi"       # Request 4Gi of memory (sufficient for many production workloads)
  }

  resource_limits = {
    cpu    = "4"         # Limit Kafka to 4 CPU cores (can scale higher with more nodes)
    memory = "8Gi"       # Allow Kafka to use up to 8Gi of memory (enough for larger loads)
  }

  # Health checks for Kafka: Liveness and readiness probes ensure
  # that Kafka is running and responsive by listing topics.
  liveness_probe = {
    initial_delay_seconds = 120
    period_seconds        = 30
    timeout_seconds       = 5
    exec_command = [
      "/opt/kafka/bin/kafka-topics.sh", "--bootstrap-server", "0.0.0.0:9092", "--list"
    ]
  }

  readiness_probe = {
    initial_delay_seconds = 120
    period_seconds        = 30
    timeout_seconds       = 5
    exec_command = [
      "/opt/kafka/bin/kafka-topics.sh", "--bootstrap-server", "0.0.0.0:9092", "--list"
    ]
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

  mount_path  = "/var/lib/kafka/data"
  pv_path     = "/mnt/data/kafka-logs"
  pv_storage  = "20Gi"
  pvc_storage = "10Gi"
}

module "redis_statefulset" {
  source         = "./modules/statefulset"
  name           = "redis"
  app_label      = "redis"
  image          = "redis:7.4.1"
  container_name = "redis"
  replicas       = 1
  container_port = 6379

  resource_requests = {
    cpu    = "1"
    memory = "1Gi"
  }

  resource_limits = {
    cpu    = "1"
    memory = "1Gi"
  }

  # Health checks for Redis: Liveness and readiness probes ensure
  # that Redis is up and responsive via the 'PING' command.
  liveness_probe = {
    initial_delay_seconds = 60
    period_seconds        = 30
    timeout_seconds       = 3
    exec_command = [
      "redis-cli", "PING"
    ]
  }

  readiness_probe = {
    initial_delay_seconds = 60
    period_seconds        = 30
    timeout_seconds       = 3
    exec_command = [
      "redis-cli", "PING"
    ]
  }

  environment = []

  labels = {
    env = "dev"
  }

  mount_path  = "/data"
  pv_path     = "/mnt/data/redis-logs"
  pv_storage  = "5Gi"
  pvc_storage = "2Gi"
}
