output "sa_private_key" {
  value = google_service_account_key.sa_key.private_key
}

output "sa_email" {
  value = google_service_account.sa.0.email
}

#output "database_url" {
#  value = gcp_db_instance == null ? null : locals.database_url
#}