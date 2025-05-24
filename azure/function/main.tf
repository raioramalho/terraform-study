provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-function-demo"
  location = "East US"
}

# Storage Account (obrigatório para Function App)
resource "azurerm_storage_account" "sa" {
  name                     = "functionsa${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# App Service Plan (consumption)
resource "azurerm_app_service_plan" "plan" {
  name                = "function-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Function App
resource "azurerm_function_app" "function" {
  name                       = "demo-function-app-${random_integer.suffix.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  version                    = "~4"

  site_config {
    linux_fx_version = "Python|3.11"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "ENV"                      = "dev"
  }
}
