# ==========================================
# Base Infrastructure
# ==========================================

resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hub_vnet_cidr
  tags                = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.spoke_vnet_cidr
  tags                = var.tags
}

# ==========================================
# Subnets & Peerings
# ==========================================

resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.fw_subnet_cidr
}

resource "azurerm_subnet" "spoke_workload" {
  #checkov:skip=CKV2_AZURE_31: Zero-Trust NSG rulesets for subnet-level isolation are included in the Enterprise Edition — woitzik.dev/templates
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = var.spoke_subnet_cidr
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ==========================================
# Azure Firewall
# ==========================================

resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-afw-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "fw" {
  #checkov:skip=CKV_AZURE_219: Firewall Policy with FQDN rule collections and dynamic IP Groups is included in the Enterprise Edition — woitzik.dev/templates
  name                = "afw-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Deny"
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.fw_subnet.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

# ==========================================
# The Loop Breaker: Forced Tunneling Routing
# ==========================================

resource "azurerm_route_table" "spoke_udr" {
  name                          = "rt-forced-tunneling-${var.environment}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  bgp_route_propagation_enabled = false
  tags                          = var.tags

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke_binding" {
  subnet_id      = azurerm_subnet.spoke_workload.id
  route_table_id = azurerm_route_table.spoke_udr.id
}
