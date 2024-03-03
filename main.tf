module "aws" {
  count         = var.aws_s3_name != null ? 1 : 0
  source        = "github.com/alexherp/terraform-aws-django?ref=stable"
  aws_s3_name   = var.aws_s3_name
  aws_s3_public = var.public_storage
  aws_sa_name   = var.cloud_sa_name
}

module "gcp" {
  count                = var.gcp_bucket_name != null ? 1 : 0
  namespace            = var.namespace
  source               = "github.com/alexherp/terraform-gcp-django?ref=stable"
  gcp_bucket_location  = var.gcp_bucket_location
  gcp_bucket_name      = var.gcp_bucket_name
  gcp_bucket_public    = var.public_storage
  gcp_db_instance      = var.gcp_db_instance
  gcp_sa_extra_roles   = var.gcp_sa_extra_roles
  gcp_sa_name          = var.cloud_sa_name
  gcp_project_id       = var.gcp_project_id
  service_account_name = var.service_account_name
}

module "postgresql" {
  count                     = var.postgres_enabled ? 1 : 0
  depends_on                = [module.django]
  source                    = "djangoflow/postgresql/kubernetes"
  version                   = "1.1.2"
  image_name                = "docker.io/postgres"
  security_context_uid      = 999
  security_context_gid      = 999
  image_tag                 = "13"
  name                      = var.service_account_name
  username                  = var.service_account_name
  namespace                 = var.namespace
  pvc_name                  = module.django.persistent_volume_claim_name
  object_prefix             = "postgres"
  resources_limits_memory   = var.postgres_resources_limits_memory
  resources_limits_cpu      = var.postgres_resources_limits_cpu
  resources_requests_memory = var.postgres_resources_requests_memory
  resources_requests_cpu    = var.postgres_resources_requests_cpu
}

module "redis" {
  count                     = var.redis_enabled ? 1 : 0
  source                    = "djangoflow/redis/kubernetes"
  namespace                 = var.namespace
  object_prefix             = "redis"
  password_required         = true
  resources_limits_memory   = var.redis_resources_limits_memory
  resources_limits_cpu      = var.redis_resources_limits_cpu
  resources_requests_memory = var.redis_resources_requests_memory
  resources_requests_cpu    = var.redis_resources_requests_cpu
}

module "cloudflare" {
  depends_on = [module.django]
  count      = var.cloudflare_enabled && length(var.ingress) > 0 ? 1 : 0
  source     = "github.com/alexherp/terraform-cloudflare-django?ref=stable"
  records    = merge({
    for k, v in var.ingress :  k => {
      value = coalesce(module.django.ingress.0.status.0.load_balancer.0.ingress.0.ip,
        module.django.ingress.0.status.0.load_balancer.0.ingress.0.hostname
      )
      type    = module.django.ingress.0.status.0.load_balancer.0.ingress.0.ip != "" ? "A" : "CNAME"
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

module "django" {
  source = "github.com/alexherp/terraform-kubernetes-app-django?ref=v0.0.2"

  # General configurations
  name                 = var.name
  namespace            = var.namespace
  create_namespace     = var.create_namespace
  extra_labels         = var.extra_labels
  image_name           = var.image_name
  image_tag            = var.image_tag
  image_pull_secrets   = var.image_pull_secrets
  image_pull_policy    = var.image_pull_policy
  env                  = var.env
  secret_env           = var.secret_env
  service_account_name = var.service_account_name

  # GCP configurations
  cloud_sa_name       = var.cloud_sa_name
  gcp_sa_extra_roles  = var.gcp_sa_extra_roles
  gcp_bucket_name     = var.gcp_bucket_name
  gcp_bucket_location = var.gcp_bucket_location
  public_storage      = var.public_storage
  gcp_add_aws_s3_env  = var.gcp_add_aws_s3_env
  gcp_db_instance     = var.gcp_db_instance

  # Deployments
  deployments = var.deployments

  # Ingress
  ingress             = var.ingress
  ingress_annotations = var.ingress_annotations

  # Cloudflare
  cloudflare_enabled = var.cloudflare_enabled

  # Postgres
  postgres_enabled      = var.postgres_enabled
  postgres_storage_size = var.postgres_storage_size

  # Redis
  redis_enabled = var.redis_enabled

  # Celery
  celery_enabled  = var.celery_enabled
  celery_db_index = var.celery_db_index

  # AWS S3
  aws_s3_name = var.aws_s3_name

  # Volumes
  volumes = var.volumes

  # Security context
  security_context_enabled = var.security_context_enabled
  security_context_gid     = var.security_context_gid
  security_context_uid     = var.security_context_uid
  security_context_fsgroup = var.security_context_fsgroup

  # Service account email
  service_account_email = var.service_account_email
}


/*module "django" {
  source = "github.com/alexherp/terraform-kubernetes-app-django?ref=v0.0.2"

  # General configurations
  name                 = "my-django-app"
  namespace            = "production"
  create_namespace     = true
  extra_labels         = { "project" = "my-django-app" }
  image_name           = "ghcr.io/your-username/django-app"
  image_tag            = "v1.0"
  image_pull_secrets   = ["dockerhub"]
  image_pull_policy    = "Always"
  env                  = { "DJANGO_SETTINGS_MODULE" = "myproject.settings.production" }
  secret_env           = { "DATABASE_URL" = "postgres://USER:PASSWORD@HOST:PORT/NAME" }
  service_account_name = "django-app-service-account"
  # GCP configurations
  cloud_sa_name        = "my-gcp-sa"
  gcp_sa_extra_roles   = ["roles/storage.objectViewer"]
  gcp_bucket_name      = "my-gcp-django-static"
  gcp_bucket_location  = "EU"
  public_storage       = true
  gcp_add_aws_s3_env   = false
  gcp_db_instance      = null
  # Deployments
  deployments          = {
    "web" = {
      pre_install_migrate       = true
      pre_install_command       = ["python", "manage.py", "migrate"]
      replicas                  = 2
      name                      = "web"
      port                      = 8000
      resources_requests_cpu    = "200m"
      resources_requests_memory = "500Mi"
      resources_limits_cpu      = "500m"
      resources_limits_memory   = "1Gi"
      liveness_probe            = {
        http_get = {
          path   = "/healthz/"
          port   = 8000
          scheme = "HTTP"
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }
      readiness_probe = {
        http_get = {
          path   = "/ready/"
          port   = 8000
          scheme = "HTTP"
        }
        initial_delay_seconds = 15
        period_seconds        = 5
      }
    }
  }
  # Ingress
  ingress = {
    "myapp.example.com" = {
      "/" = "web"
    }
  }
  ingress_annotations = {
    "kubernetes.io/ingress.class"              = "nginx"
    "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
  }
  # Cloudflare
  cloudflare_enabled       = true
  # Postgres
  postgres_enabled         = true
  postgres_storage_size    = "20Gi"
  # Redis
  redis_enabled            = true
  # Celery
  celery_enabled           = true
  celery_db_index          = "2"
  # AWS S3
  aws_s3_name              = var.aws_s3_name
  # Volumes
  volumes                  = var.volumes
  # Security context
  security_context_enabled = true
  security_context_gid     = 1000
  security_context_uid     = 1000
  security_context_fsgroup = 1000
  # Service account email
  service_account_email    = "service-account@example.com"
}*/
