# =============================================================================
# Azure Security Module - Key Vault, Managed Identity
# Multi-Cloud Disaster Recovery POC
# =============================================================================

data "azurerm_client_config" "current" {}

# --- Azure Key Vault for Secrets Management ---
resource "azurerm_key_vault" "main" {
  name                        = "${var.project_name}-${var.environment}-kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # POC - set true in production
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]

    key_permissions = [
      "Get", "List", "Create", "Delete"
    ]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Cloud       = "azure"
  }
}

# --- Store DB Credentials in Key Vault ---
resource "azurerm_key_vault_secret" "db_username" {
  name         = "db-username"
  value        = var.db_username
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.main.id
}

# --- User Assigned Managed Identity for VMs ---
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "${var.project_name}-${var.environment}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Cloud       = "azure"
  }
}

# --- Key Vault Access Policy for Managed Identity ---
resource "azurerm_key_vault_access_policy" "app_identity" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app_identity.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}
