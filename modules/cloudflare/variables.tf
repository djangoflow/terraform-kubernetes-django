variable "ingress_hostnames" {
  type = map(string)
  description = "A map of hostname:domain for ingress A records"
  default = {}
}

variable "storage_hostnames" {
  type = map(string)
  description = "A map of hostname:domain for storage"
  default = {}
}
