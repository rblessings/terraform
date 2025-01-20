module "auth_server_deployment" {
  source = "./modules/deployment"

  name           = "auth-server"
  app_label      = "auth-server"
  image          = "rblessings/oauth2-oidc-jwt-auth-server:latest"
  container_name = "auth-server"

  # TODO: The auth-server is not yet stateless-compliant.
  #       See the auth-server project issues at https://github.com/rblessings/oauth2-oidc-jwt-auth-server/issues for ongoing work.
  #       This limitation currently restricts testing to a single pod configuration.
  replicas = 1

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

  environment = []

  depends_on = [
    module.redis_auth_server_statefulset,
  ]
}

# TODO: Deploy Redis cluster for high-performance caching
#  and ensure persistence and failover configurations are optimized.

module "redis_auth_server_statefulset" {
  source = "./modules/statefulset"

  name      = "redis-auth-server"
  app_label = "redis-auth-server"

  labels = {
    app = "redis-auth-server"
  }

  image          = "redis:7.4.1"
  container_name = "redis-auth-server"
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
  pv_path    = "/mnt/data/redis-logs-auth-server"
  pv_storage = "5Gi"
}

module "redis_auth_server_svc" {
  source = "./modules/service"

  name      = "redis-auth-server-svc"
  app_label = module.redis_auth_server_statefulset.statefulset_name

  ports = [
    {
      name        = "redis-auth-server"
      port        = 6379
      target_port = 6379
    }
  ]

  depends_on = [
    module.redis_auth_server_statefulset
  ]
}