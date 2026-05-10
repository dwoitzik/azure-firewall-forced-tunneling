output "hub_vnet_id" {
  description = "The ID of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  description = "The ID of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke.id
}

output "firewall_private_ip" {
  description = "The private IP address of the Azure Firewall."
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "route_table_id" {
  description = "The ID of the Forced Tunneling Route Table."
  value       = azurerm_route_table.spoke_udr.id
}
