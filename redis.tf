module "redis" {
  count = var.redis_enabled ? 1 : 0
  source = "../terraform-kubernetes-redis"
  namespace = var.namespace
  object_prefix = "redis"
  password_required = true
  resources_limits_memory = "1Gi"
  resources_limits_cpu = "500m"
}
