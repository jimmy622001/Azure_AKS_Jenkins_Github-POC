# Monitoring Module - main.tf
# Creates monitoring resources including Log Analytics workspace and monitoring solutions

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Container Insights Solution
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  tags                  = var.tags

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# Azure Monitor Action Group
resource "azurerm_monitor_action_group" "critical" {
  name                = "critical-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "critical"
  tags                = var.tags
  
  email_receiver {
    name                    = "admin-email"
    email_address           = var.admin_email
    use_common_alert_schema = true
  }
}

# Alert for AKS CPU Usage
resource "azurerm_monitor_metric_alert" "aks_cpu_alert" {
  name                = "aks-high-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when CPU usage exceeds 80%"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# Alert for AKS Memory Usage
resource "azurerm_monitor_metric_alert" "aks_memory_alert" {
  name                = "aks-high-memory-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.aks_cluster_id]
  description         = "Alert when memory usage exceeds 80%"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# Diagnostic Settings for AKS
resource "azurerm_monitor_diagnostic_setting" "aks_diagnostics" {
  name                       = "aks-diagnostics"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  enabled_log {
    category = "kube-apiserver"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  enabled_log {
    category = "kube-controller-manager"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  enabled_log {
    category = "kube-scheduler"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  enabled_log {
    category = "kube-audit"

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}