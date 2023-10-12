output "function_apps_custom_domain_verification_id" {
  description = "The custom domain verification IDs of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.custom_domain_verification_id }
}

output "function_apps_default_hostnames" {
  description = "The default hostnames of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.default_hostname }
}

output "function_apps_identity_principal_ids" {
  description = "The Principal IDs associated with the Managed Service Identities of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.identity[0].principal_id }
}

output "function_apps_identity_tenant_ids" {
  description = "The Tenant IDs associated with the Managed Service Identities of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.identity[0].tenant_id }
}

output "function_apps_outbound_ip_addresses" {
  description = "The outbound IP addresses of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.outbound_ip_addresses }
}

output "function_apps_possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.possible_outbound_ip_addresses }
}

output "function_apps_site_credentials" {
  description = "The site credentials for the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.site_credential }
}

output "function_vnet_integration_ids" {
  description = "The IDs of the App Service Virtual Network Swift Connections."
  value       = { for conn in azurerm_app_service_virtual_network_swift_connection.function_vnet_integration : conn.name => conn.id }
}

output "linux_function_apps_ids" {
  description = "The IDs of the Linux Function Apps."
  value       = { for app in azurerm_linux_function_app.function_app : app.name => app.id }
}

output "service_plans_ids" {
  description = "The IDs of the Service Plans."
  value       = { for plan in azurerm_service_plan.service_plan : plan.name => plan.id }
}
