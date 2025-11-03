# Database Module - main.tf
# Creates Azure Database for PostgreSQL server and related resources

# Random string for PostgreSQL server name suffix
resource "random_string" "postgres_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Private DNS Zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Azure Database for PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "${var.postgres_server_name}-${random_string.postgres_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  administrator_login    = var.postgres_admin_user
  administrator_password = var.postgres_admin_password

  sku_name   = var.postgres_sku_name
  version    = var.postgres_version
  storage_mb = var.postgres_storage_mb

  backup_retention_days = 7

  # Flexible server has different networking model
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.postgres_dns.id

  # High availability settings can be added here if needed
}

# Azure Database for PostgreSQL Flexible Server database
resource "azurerm_postgresql_flexible_server_database" "postgres_db" {
  name      = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Note: Private endpoint is not required for PostgreSQL Flexible Server as it uses delegated subnet
# The private DNS zone is directly integrated with the flexible server configuration above

# PostgreSQL configuration
resource "azurerm_postgresql_flexible_server_configuration" "connection_throttling" {
  name      = "connection_throttling"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "on"
}

# Note: Firewall rules are not needed for PostgreSQL Flexible Server with delegated subnet
# as network access is controlled by subnet delegation and network security groups