 # Resource group for application resources
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# App Service Plan (Linux)
resource "azurerm_app_service_plan" "asp" {
  name                = "${var.app_name}-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# App Insights
resource "azurerm_application_insights" "ai" {
  name                = "${var.app_name}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# App Service with system-assigned identity (for Key Vault access)
resource "azurerm_app_service" "app" {
  name                = var.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    linux_fx_version = "NODE|20-lts"
    always_on        = true
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.ai.instrumentation_key
    # DATABASE_URL will be set later via Key Vault reference or via pipeline
  }
}

# Virtual Network + Subnet (for regional VNet integration)
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.app_name}-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.app_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# Regional (Swift) VNet integration for App Service
resource "azurerm_app_service_virtual_network_swift_connection" "swift" {
  app_service_id = azurerm_app_service.app.id
  subnet_id      = azurerm_subnet.subnet.id
}

# Key Vault to hold the Vercel DATABASE_URL
resource "azurerm_key_vault" "kv" {
  name                        = "${var.app_name}-kv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false
  soft_delete_enabled         = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_app_service.app.identity.principal_id
    secret_permissions = [
      "get","list"
    ]
  }
}

# Data source for client config (tenant)
data "azurerm_client_config" "current" {}

# store the Vercel DATABASE_URL as a secret in Key Vault if provided via variable
resource "azurerm_key_vault_secret" "db_secret" {
  name         = "DATABASE_URL"
  value        = var.vercel_database_url
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault.kv]
}

# Grant the App Service identity access to Key Vault (policy above covers it)
# If Key Vault is using RBAC, we'd use role assignment instead; this example uses access_policy.

# Optionally: configure Key Vault reference as app setting (Key Vault reference syntax)
resource "azurerm_app_service_slot" "dummy_slot" {
  # not used; placeholder in case slots required later
  name                = "${var.app_name}-slot"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  site_config {
    linux_fx_version = "NODE|20-lts"
  }
  # DO NOT create slot unless needed; this is a placeholder
  count = 0
}

