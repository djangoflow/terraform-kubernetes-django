resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "random_password" "password" {
  count = var.password == null ? 1 : 0
  length = 16
  special = false
}

locals {
  redis_password = coalesce(var.password, random_password.password.result)
}

resource "kubernetes_deployment_v1" "deployment" {
  depends_on       = [kubernetes_namespace_v1.namespace, random_password.password]
  wait_for_rollout = true

  metadata {
    name      = "${var.name}-master"
    namespace = var.namespace
    labels    = { app = "redis" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        role                     = "master"
        "app.kubernetes.io/name" = "${var.name}-${each.key}"
      }
    }
    template {
      metadata {
        labels = {
          role                     = each.value.role
          "app.kubernetes.io/name" = "${var.name}-${each.key}"
        }
      }

      spec {
        dynamic "image_pull_secrets" {
          for_each = {for v in var.image_pull_secrets : v => v}
          content {
            name = image_pull_secrets.key
          }
        }
        service_account_name             = var.service_account_name
        termination_grace_period_seconds = 30
        restart_policy                   = "Always"
        node_selector                    = each.value.node_selector

        volume {
          name = "secrets"
          secret {
            secret_name = kubernetes_secret_v1.secrets.metadata.0.name
          }
        }

        dynamic "security_context" {
          for_each = each.value.security_context != null ? flatten([each.value.security_context]) : []
          content {
            fs_group        = lookup(security_context.value, "fs_group", null)
            run_as_group    = lookup(security_context.value, "run_as_group", null)
            run_as_user     = lookup(security_context.value, "run_as_user", null)
            run_as_non_root = lookup(security_context.value, "run_as_non_root", null)
          }
        }

        container {
          name              = "${var.name}-${each.key}"
          image             = var.image
          image_pull_policy = var.image_pull_policy
          args              = each.value.args
          command           = each.value.command

          dynamic "env" {
            for_each = local.environment
            content {
              name  = env.key
              value = env.value
            }
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.secrets.metadata.0.name
            }
          }

          dynamic "resources" {
            for_each = each.value.resources != 0 ? [] : [{}]
            content {
              requests = {
                cpu    = lookup(var.resources, "request_cpu", null)
                memory = lookup(var.resources, "request_memory", null)
              }
              limits = {
                cpu    = lookup(var.resources, "limit_cpu", null)
                memory = lookup(var.resources, "limit_memory", null)
              }
            }
          }

          dynamic "port" {
            for_each = each.value.container_port != null ? flatten([each.value.container_port]) : []
            content {
              container_port = port.value
              name           = "http"
              protocol       = "TCP"
            }
          }

          volume_mount {
            name       = "secrets"
            mount_path = "/secrets"
            #            sub_path = ""
          }

          dynamic "liveness_probe" {
            for_each = flatten([var.liveness_probe])
            content {
              initial_delay_seconds = lookup(liveness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(liveness_probe.value, "period_seconds", null)
              timeout_seconds       = lookup(liveness_probe.value, "timeout_seconds", null)
              success_threshold     = lookup(liveness_probe.value, "success_threshold", null)
              failure_threshold     = lookup(liveness_probe.value, "failure_threshold", null)

              dynamic "http_get" {
                for_each = contains(keys(liveness_probe.value), "http_get") ? [liveness_probe.value.http_get] : []

                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = contains(keys(http_get.value), "http_header") ? http_get.value.http_header : []
                    content {
                      name  = http_header.value.name
                      value = http_header.value.value
                    }
                  }

                }
              }

              dynamic "exec" {
                for_each = contains(keys(liveness_probe.value), "exec") ? [liveness_probe.value.exec] : []

                content {
                  command = exec.value.command
                }
              }

              dynamic "tcp_socket" {
                for_each = contains(keys(liveness_probe.value), "tcp_socket") ? [liveness_probe.value.tcp_socket] : []
                content {
                  port = tcp_socket.value.port
                }
              }
            }
          }

          dynamic "readiness_probe" {
            for_each = each.value.readiness_probe != null ? flatten([each.value.readiness_probe]) : []
            content {
              initial_delay_seconds = lookup(readiness_probe.value, "initial_delay_seconds", null)
              period_seconds        = lookup(readiness_probe.value, "period_seconds", null)
              timeout_seconds       = lookup(readiness_probe.value, "timeout_seconds", null)
              success_threshold     = lookup(readiness_probe.value, "success_threshold", null)
              failure_threshold     = lookup(readiness_probe.value, "failure_threshold", null)

              dynamic "http_get" {
                for_each = contains(keys(readiness_probe.value), "http_get") ? [readiness_probe.value.http_get] : []

                content {
                  path   = lookup(http_get.value, "path", null)
                  port   = lookup(http_get.value, "port", null)
                  scheme = lookup(http_get.value, "scheme", null)
                  host   = lookup(http_get.value, "host", null)

                  dynamic "http_header" {
                    for_each = contains(keys(http_get.value), "http_header") ? http_get.value.http_header : []
                    content {
                      name  = http_header.value.name
                      value = http_header.value.value
                    }
                  }

                }
              }

              dynamic "exec" {
                for_each = contains(keys(readiness_probe.value), "exec") ? [readiness_probe.value.exec] : []

                content {
                  command = exec.value.command
                }
              }

              dynamic "tcp_socket" {
                for_each = contains(keys(readiness_probe.value), "tcp_socket") ? [readiness_probe.value.tcp_socket] : []
                content {
                  port = tcp_socket.value.port
                }
              }
            }
          }
        }
      }
    }
  }
}
