resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet_mysql"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet_mysql"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "mysql-server-celia"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  administrator_login =  "wordpress"
  administrator_password = "Witcher_95"
  delegated_subnet_id    = azurerm_subnet.subnet.id
  sku_name            = "GP_Standard_D2ads_v5"
}

resource "azurerm_mysql_flexible_database" "database" {
  name                = "mysql-database-celia"
  resource_group_name = azurerm_resource_group.aks.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_log_analytics_workspace" "wordpress_monitor" {
  name                = var.monitor_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_application_insights" "wordpress_insights" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
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
