output "database_url" {
  value = coalesce(
    module.gcp != [] ? module.gcp.0.database_url : null,
    module.postgresql != [] ? module.postgresql.0.database_url : null,
  )
}

output "google_storage_hmac_key" {
  value = module.gcp.0.google_storage_hmac_key
  sensitive = true
}

output "postgresql_url" {
  value = module.postgresql.0.database_url
}

output "postgresql_username" {
  value = module.postgresql.0.username
}

output "postgresql_password" {
  value = module.postgresql.0.password_secret
  sensitive = true
}

output "redis_url" {
  value = module.redis.0.redis_url
}

output "redis_password" {
  value = module.redis.0.password_secret
  sensitive = true
}

output "s3_endpoint_url" {
  value = module.aws.0.aws_s3_endpoint_url
}

output "s3_access_key" {
  value = module.aws.0.aws_iam_access_key
  sensitive = true
}

output "s3_endpoint_url" {
  value = module.aws.0.aws_s3_endpoint_url
}

output "s3_access_key" {
  value = module.aws.0.aws_iam_access_key
  sensitive = true
}

