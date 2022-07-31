module "gcp" {
  count                = var.gcp_bucket_name != null || var.gcp_sa_name != null ? 1 : 0
  namespace            = var.namespace
  source               = "./modules/gcp"
  gcp_bucket_name      = var.gcp_bucket_name
  gcp_sa_name          = var.gcp_sa_name
  service_account_name = var.service_account_name
}
