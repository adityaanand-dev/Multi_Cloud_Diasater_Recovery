resource "azurerm_private_dns_zone" "this" {
  name                = "${var.project_name}-${var.environment}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.project_name}-${var.environment}-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "${var.project_name}-${var.environment}-pg"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "15"
  delegated_subnet_id    = var.delegated_subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.this.id
  
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  
  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  
  backup_retention_days  = 7
  geo_redundant_backup_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
