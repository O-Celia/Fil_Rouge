resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}

/* resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "mysql-server-celia"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  administrator_login =  "wordpress"
  administrator_password = "Witcher_95"
  sku_name            = "GP_Standard_D2ads_v5"
}

resource "azurerm_mysql_flexible_database" "database" {
  name                = "mysql-database-celia"
  resource_group_name = azurerm_resource_group.aks.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
} */
/* 
resource "azurerm_mysql_flexible_server_firewall_rule" "traefik_firewall_rule" {
  name                = "allow-traefik"
  resource_group_name = azurerm_mysql_flexible_server.mysql.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = "51.145.181.57"
  end_ip_address      = "51.145.181.57"
} */

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.aks_cluster_name

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}


