resource "google_service_account" "sa" {
  account_id = var.google_sa
  display_name = "Django Service Account ${var.google_sa}"
}

resource "google_storage_hmac_key" "hmac_key" {
  depends_on = [google_service_account.sa]
  service_account_email = google_service_account.sa.email
}

resource "google_service_account_key" "sa_key" {
  depends_on = [google_service_account.sa]
  service_account_id = google_service_account.sa.name
}
