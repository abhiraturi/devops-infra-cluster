output "cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "The name of the provisioned AKS cluster"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true # This prevents the value from showing in CI logs
  description = "Raw Kubernetes configuration to connect to the cluster"
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}