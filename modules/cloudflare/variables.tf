variable "cloudflare_zones" {
  type = map(string)
  description = "A map of Cloudflare domain = zone_id"
  default = {}
}

variable "records" {
  type = map(object({
    type = string
    value = string
    proxied = bool
  }))
  description = "List of records to create"
  default = {}
}
