resource "google_storage_bucket" "media-bucket" {
  count                       = var.gcp_bucket_name != null ? 1 : 0
  name                        = var.gcp_bucket_name
  location                    = "EU"
  storage_class               = "MULTI_REGIONAL"
  uniform_bucket_level_access = true
  cors {
    max_age_seconds = 3600
    method          = [
      "GET",
    ]
    origin = [
      "*",
    ]
    response_header = [
      "Content-Type",
    ]
  }

  website {
    main_page_suffix = "index.html"
  }
}

resource "google_storage_bucket_iam_binding" "media-bucket-binding-admin" {
  count      = var.gcp_bucket_name != null && var.gcp_sa_name != null ? 1 : 0
  depends_on = [google_service_account.sa.0]
  bucket     = google_storage_bucket.media-bucket.0.name
  role       = "roles/storage.objectAdmin"
  members    = [
    "serviceAccount:${google_service_account.sa.0.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "media-bucket-binding-public" {
  count      = var.gcp_bucket_name != null && var.gcp_sa_name != null ? 1 : 0
  depends_on = [google_service_account.sa.0]
  bucket     = google_storage_bucket.media-bucket.0.name
  role       = "roles/storage.objectViewer"
  members    = [
    "allUsers"
  ]
}
