module "cloudflare" {
  depends_on = [kubernetes_ingress_v1.ingress]
  count      = var.cloudflare_enabled ? 1 : 0
  source     = "./modules/cloudflare"
  records    = merge({
  for k, v in var.ingress :  k => {
    value = coalesce(kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.ip,
      kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.hostname
    )
    type    = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.ip != "" ? "A" : "CNAME"
    proxied = false
  }
  }, var.gcp_bucket_name != null && var.public_storage == true ? {
    (var.gcp_bucket_name) = {
      value   = "c.storage.googleapis.com"
      type    = "CNAME"
      proxied = true
    }
  } : {})
}
