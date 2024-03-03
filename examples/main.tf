module "django_app" {
  source = "../"


  # General configurations
  name                 = "my-django-app"
  namespace            = "production"
  create_namespace     = true
  extra_labels         = { "project" = "my-django-app" }
  image_name           = "ghcr.io/your-username/django-app"
  image_tag            = "v1.0"
  image_pull_secrets   = ["dockerhub"]
  env                  = { "DJANGO_SETTINGS_MODULE" = "myproject.settings.production" }
  secret_env           = { "DATABASE_URL" = "postgres://USER:PASSWORD@HOST:PORT/NAME" }
  service_account_name = "django-app-service-account"
  # GCP configurations
  cloud_sa_name        = "my-gcp-sa"
  gcp_sa_extra_roles   = ["roles/storage.objectViewer"]
  gcp_bucket_name      = "my-gcp-django-static"
  gcp_project_id       = "my-gcp-project-id"
  public_storage       = true
  gcp_add_aws_s3_env   = true
  aws_s3_name          = "my-aws-s3-bucket"
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
  # Security context
  security_context_enabled = true
  security_context_gid     = 1000
  security_context_uid     = 1000
  security_context_fsgroup = 1000
  # Service account email
  service_account_email    = "service-account@example.com"

  aws_region          = "us-west-2"
  gcp_bucket_location = "us-central1"
  gcp_region          = "us-central1"
  image_pull_policy   = "IfNotPresent"
  database_url        = "postgres://postgres:5432"
  redis_url           = "redis://redis:6379"
  volumes             = [
    {
      name        = "html"
      type        = "persistent_volume_claim"
      object_name = "nginx"
      readonly    = false
      mounts      = [
        {
          mount_path = "/usr/share/nginx/html"
        }
      ]
    }
  ]

}
