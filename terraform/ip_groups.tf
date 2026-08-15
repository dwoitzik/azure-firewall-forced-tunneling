# ==========================================
# Dynamic IP Groups
# ==========================================

resource "azurerm_ip_group" "spokes" {
  name                = "ipg-spokes-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  cidrs               = var.spoke_subnet_cidr
  tags                = var.tags
}
