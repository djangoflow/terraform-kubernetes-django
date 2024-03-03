locals {
  database_url = coalesce(
    lookup(var.secret_env, "DATABASE_URL", null),
    lookup(var.env, "DATABASE_URL", null),
    var.database_url != [] ? var.database_url : null,
  )

  redis_url = coalesce(
    lookup(var.secret_env, "REDIS_URL", null),
    lookup(var.env, "REDIS_URL", null),
    var.redis_url != [] ? var.redis_url : null,
  )

  database_url_map = regex("^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<user>[^/?#:]*):(?P<password>[^/?#:]*)@(?P<hostname>[^/?#:]*):(?P<port>[0-9]*)/(?P<database>.*))?", var.database_url)

  gcp_env = var.gcp_add_aws_s3_env == false ? {} : {
    AWS_ACCESS_KEY_ID : var.gcp_access_id
    AWS_SECRET_ACCESS_KEY : var.gcp_secret
    AWS_STORAGE_BUCKET_NAME : var.gcp_bucket_name
    AWS_S3_ENDPOINT_URL : "https://storage.googleapis.com"
  }
  aws_env = var.aws_s3_name == null ? {} : {
    AWS_ACCESS_KEY_ID : var.aws_id
    AWS_SECRET_ACCESS_KEY : var.aws_secret
    AWS_STORAGE_BUCKET_NAME : var.aws_s3_name
    AWS_S3_ENDPOINT_URL : var.aws_s3_endpoint_url
  }

  env = merge(local.gcp_env, local.aws_env, var.env)

  secret_env = merge({
    "DATABASE_URL"      = local.database_url
    "REDIS_URL"         = "${local.redis_url}${var.redis_db_index}"
    "CELERY_BROKER_URL" = "${local.redis_url}${var.celery_db_index}"
    "POSTGRES_USER"     = lookup(local.database_url_map, "user")
    "POSTGRES_PASSWORD" = lookup(local.database_url_map, "password")
    "POSTGRES_HOST"     = lookup(local.database_url_map, "hostname")
    "POSTGRES_DB"       = lookup(local.database_url_map, "database")
    "POSTGRES_PORT"     = lookup(local.database_url_map, "port")
  }, var.secret_env)
}
