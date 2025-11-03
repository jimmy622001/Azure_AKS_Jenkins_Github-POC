# Database Module - outputs.tf

output "postgres_server_id" {
  description = "The ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.postgres.id
}

output "postgres_server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.postgres.name
}

output "postgres_server_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_database_name" {
  description = "The name of the PostgreSQL database"
  value       = azurerm_postgresql_flexible_server_database.postgres_db.name
}

output "postgres_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgres://${var.postgres_admin_user}@${azurerm_postgresql_flexible_server.postgres.name}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${var.postgres_db_name}"
  sensitive   = true
}

# Private endpoint IP is not used with PostgreSQL Flexible Server
# as it uses a different network model with delegated subnet