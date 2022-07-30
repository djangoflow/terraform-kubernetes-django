resource "kubernetes_service_account" "service_account" {
  depends_on = [kubernetes_namespace_v1.namespace]
  count = var.service_account_name != null ? 1 : 0
  metadata {
    name      = var.name
    namespace = var.namespace

    labels = {
      app = var.name
    }
  }

  automount_service_account_token = true
}
