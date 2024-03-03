terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "google" {
  region = var.gcp_region
}
