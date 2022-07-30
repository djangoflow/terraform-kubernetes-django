data "google_sql_database_instance" "db_instance" {
  count = var.gcp_db_instance != null ? 1 : 0
  name  = var.gcp_db_instance
}
resource "google_sql_database" "db" {
  count    = var.gcp_db_instance != null ? 1 : 0
  instance = var.gcp_db_instance
  name     = var.service_account_name
}

resource "google_sql_user" "db_user" {
  count    = var.gcp_db_instance != null ? 1 : 0
  instance = var.gcp_db_instance
  name     = var.service_account_name
  password = random_password.db_password.0.result
}

resource "random_password" "db_password" {
  count   = var.gcp_db_instance != null ? 1 : 0
  length  = 16
  special = false
}

