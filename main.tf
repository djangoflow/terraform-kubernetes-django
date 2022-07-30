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
  count = var.gcp_storage != null ? 1 : 0
  source = "./modules/gcp"
  google_storage = "storage.${var.domain}"
  google_sa = "${var.name}-${var.namespace}"
}
