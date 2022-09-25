module "redis" {
  count                     = var.redis_enabled ? 1 : 0
  source                    = "djangoflow/redis/kubernetes"
  namespace                 = var.namespace
  object_prefix             = "redis"
  password_required         = true
  resources_limits_memory   = var.redis_resources_limits_memory
  resources_limits_cpu      = var.redis_resources_limits_cpu
  resources_requests_memory = var.redis_resources_requests_memory
  resources_requests_cpu    = var.redis_resources_requests_cpu
}
