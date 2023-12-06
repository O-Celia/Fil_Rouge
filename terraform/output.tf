output "storage_account_name" {
  value = azurerm_storage_account.security_results.name
}

output "storage_account_key" {
  value     = azurerm_storage_account.security_results.primary_access_key
  sensitive = true
}

output "container_name" {
  value = azurerm_storage_container.wpscan.name
}