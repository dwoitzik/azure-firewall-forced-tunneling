# ==========================================
# The Loop Breaker: Forced Tunneling Routing
# ==========================================

resource "azurerm_route_table" "spoke_udr" {
  name                          = "rt-forced-tunneling-${var.environment}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = false
  tags                          = var.tags

  # 1. Forced Tunneling: all internet-bound traffic through the firewall.
  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

  # 2. Azure Platform Bypass: the WireServer/host endpoint every Windows VM
  #    talks to for extensions, the Guest Agent, DHCP lease renewal, and
  #    activation checks. This is the one Microsoft's own forced-tunneling
  #    docs call out explicitly — without it, VM extensions and Windows
  #    Activation break the moment traffic is forced through the firewall.
  route {
    name           = "bypass-azure-wireserver"
    address_prefix = "168.63.129.16/32"
    next_hop_type  = "Internet"
  }

  # 3. KMS Bypass: literal Windows Activation KMS endpoint, kept alongside
  #    the WireServer bypass above (some older Windows Server builds still
  #    activate against this address directly rather than via WireServer).
  route {
    name           = "bypass-azure-kms"
    address_prefix = "23.102.135.246/32"
    next_hop_type  = "Internet"
  }

  # 4. Azure AD Bypass: prevent auth lockouts on the forced-tunneled spoke.
  route {
    name           = "bypass-azure-ad"
    address_prefix = "AzureActiveDirectory"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "spoke_binding" {
  for_each       = azurerm_subnet.spoke_workload
  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.spoke_udr.id
}
