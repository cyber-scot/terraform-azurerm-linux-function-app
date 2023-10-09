resource "azurerm_service_plan" "service_plan" {
  for_each            = { for app in var.linux_function_apps : app.name => app if app.app_service_plan_name != null }
  name                = each.value.app_service_plan_name != null ? each.value.app_service_plan_name : "asp-${each.value.name}"
  resource_group_name = each.value.rg_name
  location            = each.value.location
  os_type             = each.value.os_type != null ? each.value.os_type : "Linux"
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_function_app" "function_app" {
  for_each = { for app in var.linux_function_apps : app.name => app }
  name                        = each.value.name
  service_plan_id             = each.value.service_plan_id != null ? each.value.service_plan_id : azurerm_service_plan.service_plan[each.key].id
  location                    = each.value.location
  resource_group_name         = each.value.rg_name
  app_settings                = each.value.app_settings
  https_only                  = each.value.https_only
  tags                        = each.value.tags
  builtin_logging_enabled     = each.value.builtin_logging_enabled
  client_certificate_enabled  = each.value.client_certificate_enabled
  client_certificate_mode     = each.value.client_certificate_mode
  daily_memory_time_quota     = each.value.daily_memory_time_quota
  enabled                     = each.value.enabled
  functions_extension_version = each.value.functions_extension_version

  storage_account_name       = each.value.storage_account_name != null ? each.value.storage_account_name : null
  storage_account_access_key = each.value.storage_account_access_key

  storage_key_vault_secret_id   = each.value.storage_account_name == null ? each.value.storage_key_vault_secret_id : null
  storage_uses_managed_identity = each.value.storage_account_access_key == null ? each.value.storage_uses_managed_identity : null

  dynamic "identity" {
        for_each = each.value.identity_type == "SystemAssigned" ? [each.value.identity_type] : []
        content {
          type = each.value.identity_type
        }
      }

      dynamic "identity" {
        for_each = each.value.identity_type == "SystemAssigned, UserAssigned" ? [each.value.identity_type] : []
        content {
          type         = each.value.identity_type
          identity_ids = try(each.value.identity_ids, [])
        }
      }

      dynamic "identity" {
        for_each = each.value.identity_type == "UserAssigned" ? [each.value.identity_type] : []
        content {
          type         = each.value.identity_type
          identity_ids = length(try(each.value.identity_ids, [])) > 0 ? each.value.identity_ids : []
        }
      }

  dynamic "site_config" {
    for_each = each.value.site_settings != null ? [each.value.site_settings] : []

    content {
      always_on                                     = site_config.value.always_on
      api_definition_url                            = site_config.value.api_definition_url
      api_management_api_id                         = site_config.value.api_management_api_id
      app_command_line                              = site_config.value.app_command_line
      application_insights_connection_string        = site_config.value.application_insights_connection_string
      application_insights_key                      = site_config.value.application_insights_key
      container_registry_managed_identity_client_id = site_config.value.container_registry_managed_identity_client_id
      container_registry_use_managed_identity       = site_config.value.container_registry_use_managed_identity
      elastic_instance_minimum                      = site_config.value.elastic_instance_minimum
      ftps_state                                    = site_config.value.ftps_state
      health_check_path                             = site_config.value.health_check_path
      health_check_eviction_time_in_min             = site_config.value.health_check_eviction_time_in_min
      http2_enabled                                 = site_config.value.http2_enabled
      load_balancing_mode                           = site_config.value.load_balancing_mode
      managed_pipeline_mode                         = site_config.value.managed_pipeline_mode
      minimum_tls_version                           = site_config.value.minimum_tls_version
      pre_warmed_instance_count                     = site_config.value.pre_warmed_instance_count
      remote_debugging_enabled                      = site_config.value.remote_debugging_enabled
      remote_debugging_version                      = site_config.value.remote_debugging_version
      runtime_scale_monitoring_enabled              = site_config.value.runtime_scale_monitoring_enabled
      scm_minimum_tls_version                       = site_config.value.scm_minimum_tls_version
      scm_use_main_ip_restriction                   = site_config.value.scm_use_main_ip_restriction
      use_32_bit_worker                             = site_config.value.use_32_bit_worker
      app_scale_limit                               = site_config.value.app_scale_limit
      websockets_enabled                            = site_config.value.websockets_enabled
      vnet_route_all_enabled                        = site_config.value.vnet_route_all_enabled
      worker_count                                  = site_config.value.worker_count
      default_documents                             = toset(site_config.value.default_documents)

      dynamic "application_stack" {
        for_each = site_config.value.application_stack != null ? [site_config.value.application_stack] : []
        content {
          java_version            = application_stack.value.java_version
          dotnet_version          = application_stack.value.dotnet_version
          node_version            = application_stack.value.node_version
          python_version          = application_stack.value.python_version
          powershell_core_version = application_stack.value.powershell_core_version
          use_custom_runtime      = application_stack.value.use_custom_runtime

          dynamic "docker" {
            for_each = application_stack.value.docker != null ? [application_stack.value.docker] : []
            content {
              registry_url      = docker.value.registry_url
              registry_username = docker.value.registry_username
              registry_password = docker.value.registry_password
              image_name        = docker.value.image_name
              image_tag         = docker.value.image_tag
            }
          }
        }
      }

      dynamic "app_service_logs" {
        for_each = site_config.value.app_service_logs != null ? [site_config.value.app_service_logs] : []
        content {
          disk_quota_mb         = app_service_logs.value.disk_quota_mb
          retention_period_days = app_service_logs.value.retention_period_days
        }
      }

      dynamic "cors" {
        for_each = site_config.value.cors != null ? [site_config.value.cors] : []
        content {
          allowed_origins     = cors.value.allowed_origins
          support_credentials = cors.value.support_credentials
        }
      }

      dynamic "ip_restriction" {
        for_each = site_config.value.ip_restriction != null ? [site_config.value.ip_restriction] : []

        content {
          ip_address                = ip_restriction.value.ip_address
          service_tag               = ip_restriction.value.service_tag
          virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
          name                      = ip_restriction.value.name
          priority                  = ip_restriction.value.priority
          action                    = ip_restriction.value.action

          dynamic "headers" {
            for_each = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []

            content {
              x_azure_fdid      = headers.value.x_azure_fdid
              x_fd_health_probe = headers.value.x_fd_health_prob
              x_forwarded_for   = headers.value.x_forwarded_for
              x_forwarded_host  = headers.value.x_forwarded_host
            }
          }
        }
      }

      dynamic "scm_ip_restriction" {
        for_each = site_config.value.scm_ip_restriction != null ? [site_config.value.scm_ip_restriction] : []

        content {
          ip_address                = scm_ip_restriction.value.ip_address
          service_tag               = scm_ip_restriction.value.service_tag
          virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
          name                      = scm_ip_restriction.value.name
          priority                  = scm_ip_restriction.value.priority
          action                    = scm_ip_restriction.value.action

          dynamic "headers" {
            for_each = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []

            content {
              x_azure_fdid      = headers.value.x_azure_fdid
              x_fd_health_probe = headers.value.x_fd_health_prob
              x_forwarded_for   = headers.value.x_forwarded_for
              x_forwarded_host  = headers.value.x_forwarded_host
            }
          }
        }
      }

      dynamic "connection_string" {
        for_each = each.value.connection_strings
        content {
          name  = connection_string.value.name
          type  = connection_string.value.type
          value = connection_string.value.value
        }
      }
      dynamic "sticky_settings" {
        for_each = each.value.sticky_settings != null ? [each.value.sticky_settings] : []
        content {
          app_setting_names       = sticky_settings.value.app_setting_names
          connection_string_names = sticky_settings.value.connection_string_names
        }
      }

      dynamic "backup" {
        for_each = each.value.backup != null ? [each.value.backup] : []
        content {
          name                = backup.value.name
          enabled             = backup.value.enabled
          storage_account_url = try(backup.value.storage_account_url, var.backup_sas_url)

          dynamic "schedule" {
            for_each = backup.value.schedule != null ? [backup.value.schedule] : []
            content {
              frequency_interval       = schedule.value.frequency_interval
              frequency_unit           = schedule.value.frequency_unit
              keep_at_least_one_backup = schedule.value.keep_at_least_one_backup
              retention_period_days    = schedule.value.retention_period_days
              start_time               = schedule.value.start_time
            }
          }
        }
      }
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "function_vnet_integration" {
    for_each = { for app in var.linux_function_apps : app.name => app if enable_vnet_integration == true }

  app_service_id = azurerm_linux_function_app.function_app[each.value.name].id
  subnet_id      = each.value.subnet_id
}
