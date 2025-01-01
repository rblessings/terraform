module "urlradar_svc" {
  source      = "./modules/service"
  name        = "urlradar"
  app_label   = module.urlradar_deployment.deployment_app_label
  port        = 8080
  target_port = 8080
  service_type = "NodePort"

  depends_on = [
    module.urlradar_deployment
  ]
}

module "mongodb_svc" {
  source      = "./modules/service"
  name        = "mongodb-svc"
  app_label   = module.mongodb_statefulset.statefulset_name
  port        = 27017
  target_port = 27017

  depends_on = [
    module.mongodb_statefulset
  ]
}
