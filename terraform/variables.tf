variable "resource_group_name" {
  type    = string
  default = "project_celia"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "aks_cluster_name" {
  type    = string
  default = "cluster-project"
}

variable "monitor_name" {
  type    = string
  default = "wordpress-monitor"
}

variable "app_insights_name" {
  type    = string
  default = "wordpress-insights"
}

variable "application_type" {
  type    = string
  default = "web"
}
