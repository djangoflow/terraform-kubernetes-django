resource "kubernetes_secret_v1" "secrets" {
  depends_on = [kubernetes_namespace_v1.namespace, module.gcp]
  metadata {
    name = "${var.name}-secrets"
    namespace =  var.namespace
  }
  data = merge(
    var.secrets,
    var.gcp_storage != null ? {
      "google-credentials.json" = base64decode(module.gcp.0.sa_private_key)
    } : {}
  )
}
