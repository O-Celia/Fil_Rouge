output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.security_results.name
}

output "container_name" {
  description = "The name of the storage container"
  value       = azurerm_storage_container.wpscan.name
}