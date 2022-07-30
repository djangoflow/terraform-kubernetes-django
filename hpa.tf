resource "kubernetes_horizontal_pod_autoscaler_v1" "hpa" {
  for_each   = {for k, v in local.deployments : "${var.name}-${k}" => v if v.hpa_max_replicas > 0}
  depends_on = [kubernetes_namespace_v1.namespace, module.gcp]
  metadata {
    name      = each.key
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    max_replicas = each.value.hpa_max_replicas
    min_replicas = each.value.hpa_min_replicas
    target_cpu_utilization_percentage = each.value.hpa_target_cpu
    scale_target_ref {
      kind = "Deployment"
      name = each.key
      api_version = "apps/v1"
    }
  }
}
