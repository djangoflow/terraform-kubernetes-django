locals {
  deployments = defaults(var.deployments, {
    replicas        = 1
  })

  environment = merge(var.environment,
    var.gcp_storage != null ? {
      GOOGLE_APPLICATION_CREDENTIALS = "/secrets/google-credentials.json"
    } : {})
}
