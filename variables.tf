variable "name" {
  type        = string
  description = "The name for deployment"
  default     = "django"
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to use with this installation"
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

variable "service_account_name" {
  type        = string
  description = "Name of the kubernetes service account if any"
  default     = null
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


variable "deployments" {
  type = map(object({
    name             = string
    replicas         = optional(number)
    command          = optional(list(string))
    args             = optional(list(string))
    resources        = optional(object({
      resources_requests_cpu = string
      resources_requests_memory = string
      resources_limits_cpu = string
      resources_limits_memory = string
    }))
    container_port   = optional(number)
    hpa              = optional(object({
      min_replicas = number
      max_replicas = number
      target_cpu   = number
    }))
    liveness_probe = optional(object({
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
    }))
    readiness_probe = optional(object({
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
    }))
  }))
  default = {
    "web" = {
      role    = "web"
      command = ["/start"]
      container_port = 5000
    }
    "celery-beat" = {
      role    = "celery-beat"
      command = ["/start-celerybeat"]
    }
    "celery-worker" = {
      role    = "celery-worker"
      command = ["/start-celeryworker"]
    }
  }
}

variable "rolling_update" {
  type = object({
    max_surge       = number
    max_unavailable = number
  })
  description = "Perform rolling update with these parameters, otherwise recreate"
  default     = null
}

variable "environment" {
  type        = map(string)
  description = "A map of extra environment variables"
  default     = {}
}

variable "secrets" {
  type        = map(string)
  description = "A map of extra secret environment variables"
  default     = {}
}

#variable "ingress" {
#  type = map
#  default = {
#    "web": {
#      "hostname": "web"
#      "path": "/"
#      "service": "web"
#    }
#  }
#}
#
#variable "celery_image" {
#  type = string
#  default = null
#  description = "Leave null to disable celery deployment"
#}
#
#variable "celery" {
#  default = {
#    "workers": 2
#  }
#}
#
#variable "redis_namespace" {
#  type = string
#  default = null
#}
#
#variable "postgres_namespace" {
#  type = string
#  default = null
#}
#

variable "gcp_storage" {
  type = string
  default = null
  description = "Create and use Google storage with this name"
}

variable "redis" {
  type = object({
    enabled = bool
    url = optional(string)
  })
  default = {
    enabled = false
  }
}