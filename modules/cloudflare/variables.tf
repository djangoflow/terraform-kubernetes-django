variable "records" {
  type = map(object({
    type = string
    value = string
    proxied = bool
  }))
  description = "List of records to create"
  default = {}
}
