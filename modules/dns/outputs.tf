# DNS Module Outputs

output "dns_zone_id" {
  description = "The ID of the DNS zone"
  value       = azurerm_dns_zone.main.id
}

output "dns_zone_name_servers" {
  description = "The name servers for the DNS zone"
  value       = azurerm_dns_zone.main.name_servers
}

output "cdn_profile_id" {
  description = "The ID of the CDN profile (if enabled)"
  value       = var.enable_cdn ? azurerm_cdn_profile.main[0].id : null
}

output "cdn_endpoint_id" {
  description = "The ID of the CDN endpoint (if enabled)"
  value       = var.enable_cdn ? azurerm_cdn_endpoint.main[0].id : null
}

output "cdn_endpoint_hostname" {
  description = "The hostname of the CDN endpoint (if enabled)"
  value       = var.enable_cdn ? azurerm_cdn_endpoint.main[0].host_name : null
}

output "app_dns_record" {
  description = "The FQDN of the application DNS record"
  value       = "${azurerm_dns_a_record.app.fqdn}."
}