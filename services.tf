module "urlradar_svc" {
  source       = "./modules/service"
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

module "mongodb_svc" {
  source    = "./modules/service"
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
  source    = "./modules/service"
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
  source    = "./modules/service"
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

module "elasticsearch_svc" {
  source    = "./modules/service"
  name      = "elasticsearch-svc"
  app_label = module.elasticsearch_statefulset.statefulset_name

  ports = [
    {
      name        = "http"
      port        = 9200
      target_port = 9200
    },
    {
      name        = "transport"
      port        = 9300
      target_port = 9300
    }
  ]

  depends_on = [
    module.elasticsearch_statefulset
  ]
}

