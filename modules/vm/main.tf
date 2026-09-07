resource "azurerm_network_interface" "main" {
  name                = "${var.component_name}-${var.env}-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.component_name}-${var.env}-nic"
    subnet_id                     = "/subscriptions/67d6c4c6-913c-4f47-b3e1-eab7b50d229d/resourceGroups/Nothing/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-1/subnets/snet-denmarkeast-1"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.component_name}-${var.env}"
  location                        = data.azurerm_resource_group.main.location
  resource_group_name             = data.azurerm_resource_group.main.name
  network_interface_ids           = [azurerm_network_interface.main.id]
  size                            = "Standard_B1s"
  admin_password                  = "bala@1234567"
  admin_username                  = "devops"
  source_image_id                 = var.image_id
  disable_password_authentication = false
  secure_boot_enabled             = true
  vtpm_enabled                    = true

  os_disk {

    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_dns_a_record" "main" {
  name                = "${var.component_name}-${var.env}"
  zone_name           = "piple.site"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 30
  records             = [azurerm_network_interface.main.private_ip_address]
}
