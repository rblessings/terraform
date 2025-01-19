module "urlradar_deployment" {
  source = "./modules/deployment"

  name           = "urlradar"
  app_label      = "urlradar"
  image          = "rblessings/urlradar:latest"
  container_name = "urlradar"

  replicas       = 1
  container_port = 8080

  cpu_request = "1"
  cpu_limit   = "2"

  memory_request = "1Gi"
  memory_limit   = "2Gi"

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

      # TODO: Integrate HashiCorp Vault or Kubernetes Secrets to securely manage
      #  and retrieve credentials, ensuring encryption at rest and access control.

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
      name  = "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI"
      value = "http://auth-server-svc.default.svc.cluster.local:8080"
    }
  ]

  depends_on = [
    module.mongodb_statefulset,
    module.redis_statefulset,
    module.kafka_statefulset,
    module.auth_server_deployment
  ]
}

# TODO: Deploy MongoDB replica set and enable automated data
#  backups for high availability and disaster recovery.

module "mongodb_statefulset" {
  source = "./modules/statefulset"

  name      = "mongodb"
  app_label = "mongodb"

  labels = {
    app = "mongodb"
  }

  image          = "mongo:8.0.4"
  container_name = "mongodb"
  replicas       = 1
  container_port = 27017

  resource_requests = {
    cpu    = "1"
    memory = "2Gi"
  }

  resource_limits = {
    cpu    = "2"
    memory = "4Gi"
  }

  liveness_probe = {
    initial_delay_seconds = 120
    period_seconds        = 30
    timeout_seconds       = 5
    exec_command = [
      "mongosh", "--eval", "db.adminCommand('ping').ok"
    ]
  }

  readiness_probe = {
    initial_delay_seconds = 120
    period_seconds        = 30
    timeout_seconds       = 5
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
      name = "MONGO_INITDB_ROOT_PASSWORD"

      # TODO: Integrate HashiCorp Vault or Kubernetes Secrets to securely manage
      #  and retrieve credentials, ensuring encryption at rest and access control.

      value = "secret"
    },
    {
      name  = "MONGO_INITDB_DATABASE"
      value = "urlradar"
    }
  ]

  mount_path = "/data/db"
  pv_path    = "/mnt/data/mongodb-logs"
  pv_storage = "10Gi"
}

# TODO: Set up Apache Kafka cluster for scalable event streaming
#  and ensure proper data retention policies are configured.

module "kafka_statefulset" {
  source = "./modules/statefulset"

  name      = "kafka"
  app_label = "kafka"

  labels = {
    app = "kafka"
  }

  image          = "apache/kafka:3.9.0"
  container_name = "kafka"
  replicas       = 1
  container_port = 9092

  resource_requests = {
    cpu    = "1"
    memory = "2Gi"
  }

  resource_limits = {
    cpu    = "2"
    memory = "4Gi"
  }

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

  mount_path = "/var/lib/kafka/data"
  pv_path    = "/mnt/data/kafka-logs"
  pv_storage = "10Gi"
}

# TODO: Deploy Redis cluster for high-performance caching
#  and ensure persistence and failover configurations are optimized.

module "redis_statefulset" {
  source = "./modules/statefulset"

  name      = "redis"
  app_label = "redis"

  labels = {
    app = "redis"
  }

  image          = "redis:7.4.1"
  container_name = "redis"
  replicas       = 1
  container_port = 6379

  resource_requests = {
    cpu    = "1"
    memory = "1Gi"
  }

  resource_limits = {
    cpu    = "2"
    memory = "2Gi"
  }

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

  mount_path = "/data"
  pv_path    = "/mnt/data/redis-logs"
  pv_storage = "5Gi"
}
