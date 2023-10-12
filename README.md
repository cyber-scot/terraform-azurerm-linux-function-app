
```hcl
resource "azurerm_service_plan" "service_plan" {
  for_each            = { for app in var.linux_function_apps : app.name => app if app.app_service_plan_name != null }
  name                = each.value.app_service_plan_name != null ? each.value.app_service_plan_name : "asp-${each.value.name}"
  resource_group_name = each.value.rg_name
  location            = each.value.location
  os_type             = each.value.os_type != null ? each.value.os_type : "Linux"
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_function_app" "function_app" {
  for_each                    = { for app in var.linux_function_apps : app.name => app }
  name                        = each.value.name
  service_plan_id = each.value.service_plan_id != null ? each.value.service_plan_id : lookup(azurerm_service_plan.service_plan, each.key, null).id
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

  dynamic "sticky_settings" {
    for_each = each.value.sticky_settings != null ? [each.value.sticky_settings] : []
    content {
      app_setting_names       = sticky_settings.value.app_setting_names
      connection_string_names = sticky_settings.value.connection_string_names
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

  dynamic "auth_settings" {
    for_each = each.value.auth_settings != null ? [each.value.auth_settings] : []

    content {
      enabled                        = auth_settings.value.enabled
      additional_login_parameters    = auth_settings.value.additional_login_parameters
      allowed_external_redirect_urls = auth_settings.value.allowed_external_redirect_urls
      default_provider               = auth_settings.value.default_provider
      issuer                         = auth_settings.value.issuer
      runtime_version                = auth_settings.value.runtime_version
      token_refresh_extension_hours  = auth_settings.value.token_refresh_extension_hours
      token_store_enabled            = auth_settings.value.token_store_enabled
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action

      dynamic "active_directory" {
        for_each = auth_settings.value.active_directory != null ? [auth_settings.value.active_directory] : []

        content {
          client_id         = active_directory.value.client_id
          client_secret     = active_directory.value.client_secret
          allowed_audiences = active_directory.value.allowed_audiences
        }
      }

      dynamic "facebook" {
        for_each = auth_settings.value.facebook != null ? [auth_settings.value.facebook] : []

        content {
          app_id       = facebook.value.app_id
          app_secret   = facebook.value.app_secret
          oauth_scopes = facebook.value.oauth_scopes
        }
      }

      dynamic "google" {
        for_each = auth_settings.value.google != null ? [auth_settings.value.google] : []

        content {
          client_id     = google.value.client_id
          client_secret = google.value.client_secret
          oauth_scopes  = google.value.oauth_scopes
        }
      }

      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft != null ? [auth_settings.value.microsoft] : []

        content {
          client_id     = microsoft.value.client_id
          client_secret = microsoft.value.client_secret
          oauth_scopes  = microsoft.value.oauth_scopes
        }
      }

      dynamic "twitter" {
        for_each = auth_settings.value.twitter != null ? [auth_settings.value.twitter] : []

        content {
          consumer_key    = twitter.value.consumer_key
          consumer_secret = twitter.value.consumer_secret
        }
      }

      dynamic "github" {
        for_each = auth_settings.value.github != null ? [auth_settings.value.github] : []

        content {
          client_id                  = github.value.client_id
          client_secret              = github.value.client_secret
          client_secret_setting_name = github.value.client_secret_setting_name
          oauth_scopes               = github.value.oauth_scopes
        }
      }
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
    }
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "function_vnet_integration" {
  for_each = { for app in var.linux_function_apps : app.name => app if app.enable_vnet_integration == true }

  app_service_id = azurerm_linux_function_app.function_app[each.value.name].id
  subnet_id      = each.value.subnet_id
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.function_vnet_integration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_function_app.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_service_plan.service_plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_linux_function_apps"></a> [linux\_function\_apps](#input\_linux\_function\_apps) | A list of Linux function apps to be made | <pre>list(object({<br>    name                          = string<br>    location                      = string<br>    service_plan_id               = optional(string)<br>    tags                          = map(string)<br>    rg_name                       = string<br>    app_service_plan_name         = optional(string)<br>    os_type                       = optional(string, "Linux")<br>    enable_vnet_integration       = optional(bool)<br>    subnet_id                     = optional(string)<br>    https_only                    = optional(bool)<br>    builtin_logging_enabled       = optional(bool)<br>    client_certificate_enabled    = optional(bool)<br>    client_certificate_mode       = optional(string)<br>    daily_memory_time_quota       = optional(number)<br>    enabled                       = optional(bool)<br>    functions_extension_version   = optional(string)<br>    storage_account_name          = optional(string)<br>    storage_account_access_key    = optional(string)<br>    storage_key_vault_secret_id   = optional(string)<br>    identity_ids                  = optional(list(string))<br>    identity_type                 = optional(string)<br>    storage_uses_managed_identity = optional(bool)<br>    sticky_settings = optional(object({<br>      app_setting_names       = optional(list(string))<br>      connection_string_names = optional(list(string))<br>    }))<br>    sku_name = string<br>    backup = optional(object({<br>      name                = optional(string)<br>      enabled             = optional(bool)<br>      storage_account_url = optional(string)<br>      schedule = optional(object({<br>        frequency_interval       = optional(number)<br>        frequency_unit           = optional(string)<br>        keep_at_least_one_backup = optional(bool)<br>        retention_period_days    = optional(number)<br>        start_time               = optional(string)<br>      }))<br>    }))<br>    site_settings = optional(object({<br>      always_on                                     = optional(bool)<br>      api_definition_url                            = optional(string)<br>      api_management_api_id                         = optional(string)<br>      app_command_line                              = optional(string)<br>      application_insights_connection_string        = optional(string)<br>      application_insights_key                      = optional(string)<br>      container_registry_managed_identity_client_id = optional(string)<br>      container_registry_use_managed_identity       = optional(bool)<br>      elastic_instance_minimum                      = optional(number)<br>      ftps_state                                    = optional(string)<br>      health_check_path                             = optional(string)<br>      health_check_eviction_time_in_min             = optional(number)<br>      http2_enabled                                 = optional(bool)<br>      load_balancing_mode                           = optional(string)<br>      managed_pipeline_mode                         = optional(string)<br>      minimum_tls_version                           = optional(string)<br>      pre_warmed_instance_count                     = optional(number)<br>      remote_debugging_enabled                      = optional(bool)<br>      remote_debugging_version                      = optional(string)<br>      runtime_scale_monitoring_enabled              = optional(bool)<br>      scm_minimum_tls_version                       = optional(string)<br>      scm_use_main_ip_restriction                   = optional(bool)<br>      use_32_bit_worker                             = optional(bool)<br>      app_scale_limit                               = optional(number)<br>      websockets_enabled                            = optional(bool)<br>      vnet_route_all_enabled                        = optional(bool)<br>      worker_count                                  = optional(number)<br>      default_documents                             = optional(list(string))<br>      application_stack = optional(object({<br>        java_version            = optional(string)<br>        dotnet_version          = optional(string)<br>        node_version            = optional(string)<br>        python_version          = optional(string)<br>        powershell_core_version = optional(string)<br>        use_custom_runtime      = optional(bool)<br>        docker = optional(object({<br>          registry_url      = optional(string)<br>          registry_username = optional(string)<br>          registry_password = optional(string)<br>          image_name        = optional(string)<br>          image_tag         = optional(string)<br>        }))<br>      }))<br>      app_service_logs = optional(object({<br>        disk_quota_mb         = optional(number)<br>        retention_period_days = optional(number)<br>      }))<br>      cors = optional(object({<br>        allowed_origins     = optional(list(string))<br>        support_credentials = optional(bool)<br>      }))<br>      ip_restriction = optional(list(object({<br>        ip_address                = optional(string)<br>        service_tag               = optional(string)<br>        virtual_network_subnet_id = optional(string)<br>        name                      = optional(string)<br>        priority                  = optional(number)<br>        action                    = optional(string)<br>        headers = optional(object({<br>          x_azure_fdid     = optional(string)<br>          x_fd_health_prob = optional(string)<br>          x_forwarded_for  = optional(string)<br>          x_forwarded_host = optional(string)<br>        }))<br>      })))<br>      scm_ip_restriction = optional(list(object({<br>        ip_address                = optional(string)<br>        service_tag               = optional(string)<br>        virtual_network_subnet_id = optional(string)<br>        name                      = optional(string)<br>        priority                  = optional(number)<br>        action                    = optional(string)<br>        headers = optional(object({<br>          x_azure_fdid     = optional(string)<br>          x_fd_health_prob = optional(string)<br>          x_forwarded_for  = optional(string)<br>          x_forwarded_host = optional(string)<br>        }))<br>      })))<br>      auth_settings = optional(object({<br>        enabled                        = optional(bool)<br>        additional_login_parameters    = optional(map(string))<br>        allowed_external_redirect_urls = optional(list(string))<br>        default_provider               = optional(string)<br>        issuer                         = optional(string)<br>        runtime_version                = optional(string)<br>        token_refresh_extension_hours  = optional(number)<br>        token_store_enabled            = optional(bool)<br>        unauthenticated_client_action  = optional(string)<br>        active_directory = optional(object({<br>          client_id         = optional(string)<br>          client_secret     = optional(string)<br>          allowed_audiences = optional(list(string))<br>        }))<br>        facebook = optional(object({<br>          app_id       = optional(string)<br>          app_secret   = optional(string)<br>          oauth_scopes = optional(list(string))<br>        }))<br>        google = optional(object({<br>          client_id     = optional(string)<br>          client_secret = optional(string)<br>          oauth_scopes  = optional(list(string))<br>        }))<br>        microsoft = optional(object({<br>          client_id     = optional(string)<br>          client_secret = optional(string)<br>          oauth_scopes  = optional(list(string))<br>        }))<br>        twitter = optional(object({<br>          consumer_key    = optional(string)<br>          consumer_secret = optional(string)<br>        }))<br>        github = optional(object({<br>          client_id                  = optional(string)<br>          client_secret              = optional(string)<br>          client_secret_setting_name = optional(string)<br>          oauth_scopes               = optional(list(string))<br>        }))<br>      }))<br>      backup = optional(object({<br>        name                = optional(string)<br>        enabled             = optional(bool)<br>        storage_account_url = optional(string)<br>        schedule = optional(object({<br>          frequency_interval       = optional(number)<br>          frequency_unit           = optional(string)<br>          keep_at_least_one_backup = optional(bool)<br>          retention_period_days    = optional(number)<br>          start_time               = optional(string)<br>        }))<br>      }))<br>      app_settings = optional(object({<br>        APPINSIGHTS_INSTRUMENTATIONKEY                       = optional(string)<br>        APPLICATIONINSIGHTS_CONNECTION_STRING                = optional(string)<br>        AZURE_FUNCTION_PROXY_DISABLE_LOCAL_CALL              = optional(string)<br>        AZURE_FUNCTION_PROXY_BACKEND_URL_DECODE_SLASHES      = optional(string)<br>        AZURE_FUNCTIONS_ENVIRONMENT                          = optional(string)<br>        AzureFunctionsWebHost__hostid                        = optional(string)<br>        AzureWebJobsDashboard                                = optional(string)<br>        AzureWebJobsDisableHomepage                          = optional(string)<br>        AzureWebJobsDotNetReleaseCompilation                 = optional(string)<br>        AzureWebJobsFeatureFlags                             = optional(string)<br>        AzureWebJobsKubernetesSecretName                     = optional(string)<br>        AzureWebJobsSecretStorageKeyVaultClientId            = optional(string)<br>        AzureWebJobsSecretStorageKeyVaultClientSecret        = optional(string)<br>        AzureWebJobsSecretStorageKeyVaultName                = optional(string)<br>        AzureWebJobsSecretStorageKeyVaultTenantId            = optional(string)<br>        AzureWebJobsSecretStorageKeyVaultUri                 = optional(string)<br>        AzureWebJobsSecretStorageSas                         = optional(string)<br>        AzureWebJobsSecretStorageType                        = optional(string)<br>        AzureWebJobsStorage                                  = optional(string)<br>        AzureWebJobs_TypeScriptPath                          = optional(string)<br>        DOCKER_SHM_SIZE                                      = optional(string)<br>        ENABLE_ORYX_BUILD                                    = optional(string)<br>        FUNCTION_APP_EDIT_MODE                               = optional(string)<br>        FUNCTIONS_EXTENSION_VERSION                          = optional(string)<br>        FUNCTIONS_NODE_BLOCK_ON_ENTRY_POINT_ERROR            = optional(string)<br>        FUNCTIONS_V2_COMPATIBILITY_MODE                      = optional(string)<br>        FUNCTIONS_REQUEST_BODY_SIZE_LIMIT                    = optional(string)<br>        FUNCTIONS_WORKER_PROCESS_COUNT                       = optional(string)<br>        FUNCTIONS_WORKER_RUNTIME                             = optional(string)<br>        FUNCTIONS_WORKER_SHARED_MEMORY_DATA_TRANSFER_ENABLED = optional(string)<br>        JAVA_OPTS                                            = optional(string)<br>        languageWorkers__java__arguments                     = optional(string)<br>        MDMaxBackgroundUpgradePeriod                         = optional(string)<br>        MDNewSnapshotCheckPeriod                             = optional(string)<br>        MDMinBackgroundUpgradePeriod                         = optional(string)<br>        PIP_INDEX_URL                                        = optional(string)<br>        PIP_EXTRA_INDEX_URL                                  = optional(string)<br>        PYTHON_ISOLATE_WORKER_DEPENDENCIES                   = optional(string)<br>        PYTHON_ENABLE_DEBUG_LOGGING                          = optional(string)<br>        PYTHON_ENABLE_WORKER_EXTENSIONS                      = optional(string)<br>        PYTHON_THREADPOOL_THREAD_COUNT                       = optional(string)<br>        SCALE_CONTROLLER_LOGGING_ENABLED                     = optional(string)<br>        SCM_DO_BUILD_DURING_DEPLOYMENT                       = optional(string)<br>        SCM_LOGSTREAM_TIMEOUT                                = optional(string)<br>        WEBSITE_CONTENTAZUREFILECONNECTIONSTRING             = optional(string)<br>        WEBSITE_CONTENTOVERVNET                              = optional(string)<br>        WEBSITE_CONTENTSHARE                                 = optional(string)<br>        WEBSITE_DNS_SERVER                                   = optional(string)<br>        WEBSITE_ENABLE_BROTLI_ENCODING                       = optional(string)<br>        WEBSITE_FUNCTIONS_ARMCACHE_ENABLED                   = optional(string)<br>        WEBSITE_MAX_DYNAMIC_APPLICATION_SCALE_OUT            = optional(string)<br>        WEBSITE_NODE_DEFAULT_VERSION                         = optional(string)<br>        WEBSITE_OVERRIDE_STICKY_DIAGNOSTICS_SETTINGS         = optional(string)<br>        WEBSITE_OVERRIDE_STICKY_EXTENSION_VERSIONS           = optional(string)<br>        WEBSITE_RUN_FROM_PACKAGE                             = optional(string)<br>        WEBSITE_SKIP_CONTENTSHARE_VALIDATION                 = optional(string)<br>        WEBSITE_SLOT_NAME                                    = optional(string)<br>        WEBSITE_TIME_ZONE                                    = optional(string)<br>        WEBSITE_USE_PLACEHOLDER                              = optional(string)<br>        WEBSITE_VNET_ROUTE_ALL                               = optional(string)<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
