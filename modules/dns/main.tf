# DNS and Domain Configuration Module

# DNS Zone for the domain
resource "azurerm_dns_zone" "main" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# CDN Profile (if enabled)
resource "azurerm_cdn_profile" "main" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.environment}-cdn-profile"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.cdn_sku
  tags                = var.tags
}

# CDN Endpoint (if enabled)
resource "azurerm_cdn_endpoint" "main" {
  count               = var.enable_cdn ? 1 : 0
  name                = "${var.environment}-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.main[0].name
  location            = var.location
  resource_group_name = var.resource_group_name
  origin_host_header  = var.app_service_hostname
  tags                = var.tags

  origin {
    name      = "app-origin"
    host_name = var.app_service_hostname
  }

  # Add custom domain if specified
  dynamic "custom_domain" {
    for_each = var.custom_domain != "" ? [1] : []
    
    content {
      name = var.custom_domain
    }
  }

  # CDN configuration
  optimization_type = var.cdn_optimization_type
  
  # Caching rules
  delivery_rule {
    name  = "CacheRule"
    order = 1
    
    cache_expiration_action {
      behavior = "SetIfMissing"
      duration = var.cdn_cache_duration
    }
  }
}

# DNS A Record for application (non-CDN or points to CDN)
resource "azurerm_dns_a_record" "app" {
  name                = var.environment == "prod" ? "@" : var.environment
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  target_resource_id  = var.enable_cdn ? azurerm_cdn_endpoint.main[0].id : var.app_service_id
}

# DNS CNAME record for www (production only)
resource "azurerm_dns_cname_record" "www" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "www"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.domain_name
}