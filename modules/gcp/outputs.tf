output "sa_email" {
  value = google_service_account.sa.0.email
}

output "database_url" {
  value = var.gcp_db_instance == null ? null : "postgres://${var.service_account_name}:${random_password.db_password.0.result}@${data.google_sql_database_instance.db_instance.0.private_ip_address}:5432/${var.service_account_name}"
}

# DEPRECATED
# No longer required with workload identity
#output "sa_private_key" {
#  value = google_service_account_key.sa_key.private_key
#}
