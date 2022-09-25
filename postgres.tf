resource "kubernetes_persistent_volume_claim_v1" "pgdata" {
  count = var.postgres_enabled ? 1 : 0
  metadata {
    name      = "postgres-data"
    namespace = var.namespace
    labels    = local.common_labels
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.postgres_storage_size
      }
    }
  }
}


module "postgresql" {
  count                     = var.postgres_enabled ? 1 : 0
  depends_on                = [kubernetes_persistent_volume_claim_v1.pgdata]
  source                    = "djangoflow/postgresql/kubernetes"
  version                   = "1.1.2"
  image_name                = "docker.io/postgres"
  security_context_uid      = 999
  security_context_gid      = 999
  image_tag                 = "13"
  name                      = var.service_account_name
  username                  = var.service_account_name
  namespace                 = var.namespace
  pvc_name                  = kubernetes_persistent_volume_claim_v1.pgdata.0.metadata.0.name
  object_prefix             = "postgres"
  resources_limits_memory   = var.postgres_resources_limits_memory
  resources_limits_cpu      = var.postgres_resources_limits_cpu
  resources_requests_memory = var.postgres_resources_requests_memory
  resources_requests_cpu    = var.postgres_resources_requests_cpu
}
