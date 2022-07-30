terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.0"
    }
  }
  experiments = [
    module_variable_optional_attrs
  ]
}

module "gcp" {
  count                = var.gcp_bucket_name != null || var.gcp_sa_name != null ? 1 : 0
  namespace            = var.namespace
  source               = "./modules/gcp"
  gcp_bucket_name      = var.gcp_bucket_name
  gcp_sa_name          = var.gcp_sa_name
  service_account_name = var.service_account_name
}

module "cloudflare" {
  depends_on = [kubernetes_ingress_v1.ingress]
  count      = length(keys(var.cloudflare_zones)) > 0 ? 1 : 0
  source     = "./modules/cloudflare"
  cloudflare_zones = var.cloudflare_zones
  records    = merge({
  for k, v in var.ingress :  k => {
    value   = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.ip
    type    = "A"
    proxied = false
  }
  })
}
