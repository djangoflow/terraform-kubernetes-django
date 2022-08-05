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
variable "gcp_sa_name" {
  type        = string
  description = "Name of the GCP service account if any"
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

variable "gcp_db_instance" {
  type        = string
  default     = null
  description = "Create a database and a user for this installation and use them instead of DATABASE_URL"
}

# Deployments
variable "deployments" {
  type = map(object({
    name                      = string
    replicas                  = optional(number)
    command                   = optional(list(string))
    args                      = optional(list(string))
    port                      = optional(number)
    resources_requests_cpu    = optional(string)
    resources_requests_memory = optional(string)
    resources_limits_cpu      = optional(string)
    resources_limits_memory   = optional(string)
    pdb_min_available         = optional(number)
    hpa_min_replicas          = optional(number)
    hpa_max_replicas          = optional(number)
    hpa_target_cpu            = optional(number)
    pre_install_migrate       = optional(bool)
    liveness_probe            = optional(object({
      enabled  = bool
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
      enabled  = bool
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
      replicas                  = 1
      name                      = "web"
      args                      = ["/start"]
      port                      = 5000
      resources_limits_cpu      = "250m"
      resources_limits_memory   = "2Gi"
      resources_requests_cpu    = "100m"
      resources_requests_memory = "512M"
      #      hpa_min_replicas = 1
      #      hpa_max_replicas = 2
      #      hpa_target_cpu = 70
      liveness_probe            = {
        enabled = true
      }
      readiness_probe = {
        enabled = true
      }
    }
    "celery-beat" = {
      replicas       = 1
      name           = "celery-beat"
      args           = ["/start-celerybeat"]
      port           = 0
      liveness_probe = {
        enabled = false
      }
      readiness_probe = {
        enabled = false
      }
      resources_limits_cpu      = "250m"
      resources_limits_memory   = "512M"
      resources_requests_cpu    = "30m"
      resources_requests_memory = "64M"
    }
    "celery-worker" = {
      replicas       = 1
      name           = "celery-worker"
      args           = ["/start-celeryworker"]
      port           = 0
      liveness_probe = {
        enabled = false
      }
      readiness_probe = {
        enabled = false
      }
      resources_limits_cpu      = "250m"
      resources_limits_memory   = "512M"
      resources_requests_cpu    = "30m"
      resources_requests_memory = "64M"
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
variable "cloudflare_zones" {
  description = "A map of Cloudflare domain = zone_id, will create cloudflare records if supplied"
  type        = map(string)
  default     = {}
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

variable "redis_enabled" {
  description = "Create a redis database deployment"
  type        = bool
  default     = false
}

variable "redis_resources_memory" {
  type    = string
  default = "512M"
}

variable "redis_resources_cpu" {
  type    = string
  default = "200m"
}
