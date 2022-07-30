resource "kubernetes_pod_disruption_budget_v1" "pdb" {
  for_each   = {for k, v in local.deployments : "${var.name}-${k}" => v if v.pdb_min_available > 0}
  depends_on = [kubernetes_namespace_v1.namespace, module.gcp]
  metadata {
    name      = each.key
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    min_available = each.value.pdb_min_available
    selector {
      match_labels = merge(local.common_labels, {
        "app.kubernetes.io/name"     = each.key
        "app.kubernetes.io/instance" = var.image_tag
      })
    }
  }
}
