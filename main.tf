# Nothing here, see instead:
#
# gcp.tf
# postgres.tf
# redis.tf
# cloudflare.tf

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.0"
    }
  }
}
