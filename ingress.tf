resource "kubernetes_ingress_v1" "ingress" {
  count = length(var.ingress) > 0 ? 1 : 0
  metadata {
    name        = var.name
    namespace   = var.namespace
    annotations = local.ingress_annotations
  }
  spec {
    tls {
      hosts       = keys(var.ingress)
      secret_name = "${var.name}-tls-secret"
    }
    dynamic "rule" {
      for_each = var.ingress
      content {
        host = rule.key
        http {
          dynamic "path" {
            for_each = rule.value
            content {
              path = path.key
              backend {
                service {
                  name = "${var.name}-${path.value}"
                  port {
                    number = 80
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
