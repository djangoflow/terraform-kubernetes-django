terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

data "cloudflare_zones" "zones" {
  filter {}
}

locals {
  zones = {for zone in data.cloudflare_zones.zones.zones : zone.name => zone.id}
}


resource "cloudflare_record" "record" {
  for_each = var.records
  name     = each.key
  type     = each.value.type
  value    = each.value.value
  proxied  = each.value.proxied
  zone_id  = lookup(local.zones, regex(".*?([^.]+\\.[^.]+)$", each.key)[0])
  lifecycle {
    ignore_changes = [zone_id]
  }
}
