resource "kubernetes_secret_v1" "secrets" {
  depends_on = [kubernetes_namespace_v1.namespace]
  metadata {
    name      = "${var.name}-secrets"
    namespace = var.namespace
  }
  data = local.secret_env
}
