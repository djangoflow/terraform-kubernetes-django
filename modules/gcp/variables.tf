variable "namespace" {
  type = string
}

variable "gcp_sa_name" {
  type = string
  default = null
}

variable "gcp_bucket_name" {
  type = string
  default = null
}

variable "service_account_name" {
  type = string
  default = null
}

variable "gcp_db_instance" {
  type = string
  default = null
  description = "Create a database and a user for this installation and use them instead of DATABASE_URL"
}
