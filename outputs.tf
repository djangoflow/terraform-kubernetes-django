output "database_url" {
  value = coalesce(
    module.gcp != [] ? module.gcp.0.database_url : null,
    module.postgresql != [] ? module.postgresql.0.database_url : null,
  )
}
