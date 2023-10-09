module "rg" {
  source = "cyber-scot/rg/azurerm"

  name     = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}


module "fnc_app" {
  source = "../../"
  linux_function_apps = [
    {
      name = "fnc-${var.short}-${var.loc}-${var.env}-01"

      rg_name  = module.rg.rg_name
      location = module.rg.rg_location
      tags     = module.rg.rg_tags

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
