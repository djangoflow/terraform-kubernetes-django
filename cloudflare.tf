module "cloudflare" {
  depends_on = [kubernetes_ingress_v1.ingress]
  count      = var.cloudflare_enabled ? 1 : 0
  source     = "./modules/cloudflare"
  records    = merge({
  for k, v in var.ingress :  k => {
    value   = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.ip
    type    = "A"
    proxied = false
  }
  }, var.gcp_bucket_name == null || var.gcp_bucket_public == false ? {} : {
    (var.gcp_bucket_name) = {
      value   = "c.storage.googleapis.com"
      type    = "CNAME"
      proxied = true
    }
  })
}
