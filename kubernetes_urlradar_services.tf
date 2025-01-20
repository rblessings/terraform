# TODO: Replace NodePort with Ingress for all services to streamline external access management.
#       Benefits include centralized routing, improved security, and enhanced scalability.

module "urlradar_svc" {
  source = "./modules/service"

  name         = "urlradar-svc"
  app_label    = module.urlradar_deployment.deployment_app_label
  service_type = "NodePort"

  ports = [
    {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  ]

  depends_on = [
    module.urlradar_deployment
  ]
}

module "auth-server-svc" {
  source = "./modules/service"

  name         = "auth-server-svc"
  app_label    = module.auth_server_deployment.deployment_app_label
  service_type = "NodePort"

  ports = [
    {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  ]

  depends_on = [
    module.auth_server_deployment
  ]
}

module "mongodb_svc" {
  source = "./modules/service"

  name      = "mongodb-svc"
  app_label = module.mongodb_statefulset.statefulset_name

  ports = [
    {
      name        = "mongodb"
      port        = 27017
      target_port = 27017
    }
  ]

  depends_on = [
    module.mongodb_statefulset
  ]
}

module "redis_svc" {
  source = "./modules/service"

  name      = "redis-svc"
  app_label = module.redis_statefulset.statefulset_name

  ports = [
    {
      name        = "redis"
      port        = 6379
      target_port = 6379
    }
  ]

  depends_on = [
    module.redis_statefulset
  ]
}

module "kafka_svc" {
  source = "./modules/service"

  name      = "kafka-svc"
  app_label = module.kafka_statefulset.statefulset_name

  ports = [
    {
      name        = "kafka"
      port        = 9092
      target_port = 9092
    }
  ]

  depends_on = [
    module.kafka_statefulset
  ]
}
