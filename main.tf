# Nothing here, see instead:
#
# gcp.tf
# postgres.tf
# redis.tf
# cloudflare.tf

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
