# General
variable "name" {
  type        = string
  description = "The name for deployment"
  default     = "django"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use with this installation"
}

variable "create_namespace" {
  default     = true
  description = "Should we create the namespace or use existing provided?"
}

variable "extra_labels" {
  type        = map(string)
  default     = {}
  description = "Extra labels to add to generated objects"
}

variable "image_name" {
  type        = string
  description = "Docker image repository and name"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
}

variable "image_pull_secrets" {
  type        = list(string)
  description = "Image pull secrets"
  default     = []
}

variable "image_pull_policy" {
  type        = string
  default     = "IfNotPresent"
  description = "Pull policy for the images"
}

variable "env" {
  type        = map(string)
  description = "A map of extra environment variables"
  default     = {}
}

variable "secret_env" {
  type        = map(string)
  description = "A map of extra secret environment variables"
}

variable "service_account_name" {
  type        = string
  description = "Name of the kubernetes service account if any"
  default     = null
}

# GCP (Google Cloud Platform)
variable "cloud_sa_name" {
  type        = string
  description = "Name of the GCP/AWS service account if any"
  default     = null
}

variable "gcp_sa_extra_roles" {
  type        = list(string)
  description = "Create role bindings to these roles"
  default     = null
}

variable "gcp_bucket_name" {
  type        = string
  default     = null
  description = "Create and use Google storage with this name"
}

variable "gcp_bucket_location" {
  type        = string
  description = "The location of the bucket, e.g. EU or US"
}

variable "public_storage" {
  type        = bool
  default     = true
  description = "Make the storge GCP bucket/AWS S3 public and create a CNAME"
}

variable "gcp_add_aws_s3_env" {
  type        = bool
  default     = false
  description = "Add AWS_ variables for the GCS bucket"
}

variable "gcp_db_instance" {
  type        = string
  default     = null
  description = "Create a database and a user for this installation and use them instead of DATABASE_URL"
}


# Deployments
variable "deployments" {
  type = map(object({
    name                      = string
    replicas                  = optional(number, 1)
    command                   = optional(list(string))
    args                      = optional(list(string), ["/start"])
    port                      = optional(number)
    resources_requests_cpu    = optional(string, "100m")
    resources_requests_memory = optional(string, "256Mi")
    resources_limits_cpu      = optional(string, "1000m")
    resources_limits_memory   = optional(string, "2Gi")
    pdb_min_available         = optional(number, 0)
    hpa_min_replicas          = optional(number, 0)
    hpa_max_replicas          = optional(number, 0)
    hpa_target_cpu            = optional(number, 80)
    pre_install_migrate       = optional(bool, false)
    pre_install_command       = optional(list(string), [])
    env                       = optional(map(string))
    liveness_probe            = optional(object({
      enabled  = optional(bool, true)
      http_get = optional(object({
        path   = string
        port   = number
        scheme = string
      }))
      success_threshold     = optional(number)
      failure_threshold     = optional(number)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    }))
    readiness_probe = optional(object({
      enabled  = optional(bool, true)
      http_get = optional(object({
        path   = string
        port   = number
        scheme = string
      }))
      success_threshold     = optional(number)
      failure_threshold     = optional(number)
      initial_delay_seconds = optional(number)
      period_seconds        = optional(number)
      timeout_seconds       = optional(number)
    }))
  }))
  default = {
    "web" = {
      pre_install_migrate = true
      pre_install_command = []
      replicas            = 1
      name                = "web"
      port                = 5000
    }
  }
}

variable "readiness_probe" {
  type = object({
    http_get = object({
      path   = string
      port   = number
      scheme = string
    })
    success_threshold     = number
    failure_threshold     = number
    initial_delay_seconds = number
    period_seconds        = number
    timeout_seconds       = number
  })
  description = "Readiness probe for containers which have ports"
  default     = {
    http_get = {
      path   = "/healthz/"
      port   = 5000
      scheme = "HTTP"
    }
    success_threshold     = 1
    failure_threshold     = 3
    initial_delay_seconds = 10
    period_seconds        = 30
    timeout_seconds       = 3
  }
}

variable "liveness_probe" {
  type = object({
    http_get = object({
      path   = string
      port   = number
      scheme = string
    })
    success_threshold     = number
    failure_threshold     = number
    initial_delay_seconds = number
    period_seconds        = number
    timeout_seconds       = number
  })
  description = "Liveness probe for containers which have ports"
  default     = {
    http_get = {
      path   = "/healthz/"
      port   = 5000
      scheme = "HTTP"
    }
    success_threshold     = 1
    failure_threshold     = 3
    initial_delay_seconds = 10
    period_seconds        = 30
    timeout_seconds       = 3
  }
}

# Ingress
variable "ingress" {
  type        = map(map(string))
  description = "A map of hostnames with maps of path-names and services"
  # Example:
  #  default     = {
  #    "api.demo.djangoflow.com": {
  #      "/": "api"
  #    }
  #  }
}

variable "ingress_annotations" {
  type    = map(string)
  default = {}
}

# Cloudflare
variable "cloudflare_enabled" {
  description = "Create cloudflare records if true"
  type        = bool
  default     = true
}

# Extras
variable "postgres_enabled" {
  description = "Create a postgres database deployment"
  type        = bool
  default     = false
}

variable "postgres_storage_size" {
  default = "10Gi"
}

variable "postgres_resources_requests_memory" {
  type    = string
  default = "256Mi"
}

variable "postgres_resources_requests_cpu" {
  type    = string
  default = "250m"
}

variable "postgres_resources_limits_memory" {
  type    = string
  default = null
}

variable "postgres_resources_limits_cpu" {
  type    = string
  default = null
}

variable "redis_enabled" {
  description = "Create a redis database deployment"
  type        = bool
  default     = false
}

variable "redis_resources_limits_memory" {
  type    = string
  default = null
}

variable "redis_resources_limits_cpu" {
  type    = string
  default = null
}

variable "redis_resources_requests_memory" {
  type    = string
  default = "128Mi"
}

variable "redis_resources_requests_cpu" {
  type    = string
  default = "50m"
}

variable "redis_db_index" {
  default = "1"
}

variable "celery_enabled" {
  description = "A short-hand for adding celery-beat and celery-worker deployments"
  default     = true
}

variable "celery_db_index" {
  default = "2"
}

variable "celery_beat_defaults" {
  default = {
    replicas            = 1
    name                = "celery-beat"
    command             = null
    pre_install_migrate = false
    pre_install_command = []
    args                = ["/start-celerybeat"]
    port                = 0
    liveness_probe      = {
      enabled = false
    }
    readiness_probe = {
      enabled = false
    }
    resources_limits_cpu      = "250m"
    resources_limits_memory   = "256Mi"
    resources_requests_cpu    = "30m"
    resources_requests_memory = "90Mi"
    pdb_min_available         = 0
    hpa_max_replicas          = 0
    env                       = {}
  }
}

variable "celery_worker_defaults" {
  default = {
    replicas            = 1
    name                = "celery-worker"
    command             = null
    pre_install_migrate = false
    pre_install_command = []
    args                = ["/start-celeryworker"]
    port                = 0
    liveness_probe      = {
      enabled = false
    }
    readiness_probe = {
      enabled = false
    }
    resources_limits_cpu      = "900m"
    resources_limits_memory   = "768Mi"
    resources_requests_cpu    = "100m"
    resources_requests_memory = "128Mi"
    pdb_min_available         = 0
    hpa_max_replicas          = 0
    env                       = {}
  }
}

variable "aws_s3_name" {
  type        = string
  default     = null
  description = "Create and use AWS S3"
}

variable "volumes" {
  type        = any
  description = "Volume configuration"
  default     = []
}

variable "security_context_enabled" {
  type    = bool
  default = false
}

variable "security_context_gid" {
  default = 101
}

variable "security_context_uid" {
  default = 101
}

variable "security_context_fsgroup" {
  default = null
}
