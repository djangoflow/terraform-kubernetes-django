#resource "google_sql_database" "db" {
#  count = var.gcp_db_instance != null ? 1 : 0
#  instance = var.gcp_db_instance
#  name = var.service_account_name
#}
#
#resource "google_sql_user" "db_user" {
#  count = var.gcp_db_instance != null ? 1 : 0
#  instance = var.gcp_db_instance
#  name = var.service_account_name
#  password = random_password.db_password.0.result
#}
#
#resource "random_password" "db_password" {
#  count = var.gcp_db_instance != null ? 1 : 0
#  length = 16
#  special = false
#}
#
#locals {
#  database_url = "postgres://${var.service_account_name}:{@django-postgresql.ge-dev.svc.cluster.local:5432/ge-dev"
#}