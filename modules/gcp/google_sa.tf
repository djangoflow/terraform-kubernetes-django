resource "google_service_account" "sa" {
  count        = var.gcp_sa_name != null ? 1 : 0
  account_id   = var.gcp_sa_name
  display_name = "Django Service Account ${var.gcp_sa_name}"
}

resource "google_storage_hmac_key" "hmac_key" {
  depends_on            = [google_service_account.sa]
  service_account_email = google_service_account.sa.0.email
}

resource "google_service_account_key" "sa_key" {
  depends_on         = [google_service_account.sa]
  service_account_id = google_service_account.sa.0.name
}

resource "google_service_account_iam_member" "workloadIdentity" {
  service_account_id = google_service_account.sa.0.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${google_service_account.sa.0.project}.svc.id.goog[${var.namespace}/${var.service_account_name}]"
}

resource "google_project_iam_binding" "firebaseAdmin" {
  for_each   = {for k, v in var.gcp_sa_extra_roles : k => v}
  role       = each.value
  members    = ["serviceAccount:${google_service_account.sa.0.email}"]
  depends_on = [google_service_account.sa]
  project    = google_service_account.sa[0].project
}
