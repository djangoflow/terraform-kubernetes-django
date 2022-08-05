terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

resource "cloudflare_record" "record" {
  for_each = var.records
  name     = each.key
  type     = each.value.type
  value    = each.value.value
  proxied  = each.value.proxied
  zone_id  = lookup(var.cloudflare_zones, regex("^\\w+\\.(.+)$",each.key)[0])
}
