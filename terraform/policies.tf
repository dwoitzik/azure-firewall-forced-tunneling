# ==========================================
# Firewall Policies & Rule Collections
# ==========================================

resource "azurerm_firewall_policy" "base_policy" {
  #checkov:skip=CKV_AZURE_220: IDPS mode=Deny requires Premium SKU (~+€1/h). Upgrade sku to "Premium" and add intrusion_detection { mode = "Deny" } to enable it.
  name                = "afwp-base-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
  name               = "app-rule-collection"
  firewall_policy_id = azurerm_firewall_policy.base_policy.id
  priority           = 1000

  application_rule_collection {
    name     = "allow-core-msft-services"
    priority = 1100
    action   = "Allow"

    rule {
      name = "allow-windows-updates"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_ip_groups = [azurerm_ip_group.spokes.id]
      destination_fqdns = [
        "*.download.windowsupdate.com",
        "*.microsoft.com",
        "*.windowsupdate.com"
      ]
    }
  }
}
