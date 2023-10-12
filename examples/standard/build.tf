module "rg" {
  source = "cyber-scot/rg/azurerm"

  name     = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

resource "azurerm_user_assigned_identity" "uid" {
  name                = "uid-${var.short}-${var.loc}-${var.env}-01"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
  tags                = module.rg.rg_tags
}

module "network" {
  source = "cyber-scot/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    "sn1-${module.network.vnet_name}" = {
      address_prefixes  = ["10.0.0.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}

module "sa" {
  source = "cyber-scot/storage-account/azurerm"
  storage_accounts = [
    {
      name     = "sa${var.short}${var.loc}${var.env}01"
      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      identity_type = "UserAssigned"
      identity_ids  = [azurerm_user_assigned_identity.uid.id]

      network_rules = {
        bypass                     = ["AzureServices"]
        default_action             = "Deny"
        ip_rules                   = [chomp(data.http.client_ip.response_body)]
        virtual_network_subnet_ids = [module.network.subnets_ids["sn1-${module.network.vnet_name}"]]
      }
    },
  ]
}



module "fnc_app" {
  source = "cyber-scot/linux-function-app/azurerm"
  linux_function_apps = [
    {
      name                  = "fnc-${var.short}-${var.loc}-${var.env}-01"
      app_service_plan_name = "asp-${var.short}-${var.loc}-${var.env}-01"

      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

      identity_type                 = "UserAssigned"
      identity_ids                  = [azurerm_user_assigned_identity.uid.id]
      storage_account_name          = module.sa.storage_account_names["sa${var.short}${var.loc}${var.env}01"]
      storage_uses_managed_identity = true

      sku_name = "Y1"
      app_settings = {
        FUNCTIONS_WORKER_RUNTIME = "python"
      }
      site_settings = {
        application_stack = {
          python_version = "3.9"
        }
      }
    }
  ]
}
