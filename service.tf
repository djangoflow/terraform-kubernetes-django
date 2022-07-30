resource "kubernetes_service" "service" {
  for_each = {for k, v in local.deployments : k => v if v.container_port != null}
  metadata {
    name      = each.key
    namespace = var.namespace

    labels = {
      app = var.name
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = each.value.container_port
      target_port = "http"
    }

    selector = {
      role = each.key
    }

    type = "ClusterIP"
  }
}
