resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_A4_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

    oms_agent {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.wordpress_monitor.id
  }
}

resource "azurerm_log_analytics_workspace" "wordpress_monitor" {
  name                = var.monitor_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.resource_group_name
}


resource "azurerm_storage_account" "security_results" {
  name                     = var.storage
  resource_group_name      = azurerm_resource_group.aks.name
  location                 = azurerm_resource_group.aks.location
  account_tier             = var.storage_tier
  account_replication_type = var.replication_type
}

resource "azurerm_storage_container" "wpscan" {
  name                  = var.container_storage
  storage_account_name  = azurerm_storage_account.security_results.name
}
