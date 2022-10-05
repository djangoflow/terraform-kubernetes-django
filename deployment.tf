module "deployment" {
  #  source     = "../terraform-kubernetes-deployment"
  source     = "djangoflow/deployment/kubernetes"
  version    = ">=1.6.0"
  for_each   = local.deployments
  depends_on = [kubernetes_secret_v1.secrets]

  pre_install_job_command = each.value.pre_install_migrate == true ? ["python", "manage.py", "migrate"] : []

  service_account_name          = var.service_account_name
  object_prefix                 = "${var.name}-${each.key}"
  replicas                      = each.value.replicas
  command                       = each.value.command
  arguments                     = each.value.args
  image_name                    = var.image_name
  image_tag                     = var.image_tag
  image_pull_secrets            = var.image_pull_secrets
  pull_policy                   = var.image_pull_policy
  namespace                     = var.namespace
  readiness_probe_enabled       = each.value.readiness_probe.enabled
  readiness_probe_path          = var.readiness_probe.http_get.path
  readiness_probe_port          = var.readiness_probe.http_get.port
  readiness_probe_scheme        = var.readiness_probe.http_get.scheme
  readiness_probe_initial_delay = var.readiness_probe.initial_delay_seconds
  readiness_probe_timeout       = var.readiness_probe.timeout_seconds
  readiness_probe_failure       = var.readiness_probe.failure_threshold
  readiness_probe_success       = var.readiness_probe.success_threshold
  liveness_probe_enabled        = each.value.liveness_probe.enabled
  liveness_probe_path           = var.liveness_probe.http_get.path
  liveness_probe_port           = var.liveness_probe.http_get.port
  liveness_probe_scheme         = var.liveness_probe.http_get.scheme
  liveness_probe_initial_delay  = var.liveness_probe.initial_delay_seconds
  liveness_probe_timeout        = var.liveness_probe.timeout_seconds
  liveness_probe_failure        = var.liveness_probe.failure_threshold
  liveness_probe_success        = var.liveness_probe.success_threshold
  startup_probe_enabled         = false
  security_context_enabled      = false
  env                           = each.value.env == null ? local.env : merge(local.env, each.value.env)
  resources_limits_cpu          = each.value.resources_limits_cpu
  resources_limits_memory       = each.value.resources_limits_memory
  resources_requests_cpu        = each.value.resources_requests_cpu
  resources_requests_memory     = each.value.resources_requests_memory
  labels                        = merge(local.common_labels, {
    "app.kubernetes.io/instance" = "${var.name}-${each.key}"
    "app.kubernetes.io/version"  = var.image_tag
  })

  env_secret = [
  for k, v in    local.secret_env : {
    secret = "${var.name}-secrets"
    name   = k
    key    = k
  }
  ]
  node_selector = var.gcp_bucket_name != null && var.cloud_sa_name != null ? {
    "iam.gke.io/gke-metadata-server-enabled" = "true"
  } : {}
  ports = each.value.port > 0 ? [
    {
      name           = "http"
      protocol       = "TCP"
      container_port = each.value.port
      service_port   = "80"
    }
  ] : []
}
