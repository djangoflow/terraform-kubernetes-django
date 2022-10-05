module "gcp" {
  count                = var.gcp_bucket_name != null ? 1 : 0
  namespace            = var.namespace
  source               = "./modules/gcp"
  gcp_bucket_name      = var.gcp_bucket_name
  gcp_bucket_public    = var.public_storage
  gcp_sa_name          = var.cloud_sa_name
  gcp_sa_extra_roles   = var.gcp_sa_extra_roles
  gcp_db_instance      = var.gcp_db_instance
  service_account_name = var.service_account_name
}
