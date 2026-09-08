resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.component_name}-${var.env}-nic${count.index}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.component_name}-${var.env}-nic${count.index}"
    subnet_id                     = "/subscriptions/67d6c4c6-913c-4f47-b3e1-eab7b50d229d/resourceGroups/Nothing/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-2/subnets/snet-denmarkeast-1"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.component_name}-${var.env}-${count.index}"
  location                        = data.azurerm_resource_group.main.location
  resource_group_name             = data.azurerm_resource_group.main.name
  network_interface_ids           = [azurerm_network_interface.main[count.index].id]
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
  records             = var.lb_type == null ? [azurerm_network_interface.main[0].private_ip_address] : var.lb_type == "public" ? azurerm_public_ip.main[*].ip_address : azurerm_lb.main[*].private_ip_address
}

resource "azurerm_public_ip" "main" {
  count               = var.lb_type == "public" ? 1 : 0
  name                = "${var.component_name}-${var.env}-lb"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
}


resource "azurerm_lb" "main" {
  count               = var.lb_type != null ? 1 : 0
  name                = "${var.component_name}-${var.env}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                          = "${var.component_name}-${var.env}"
    private_ip_address_allocation = var.lb_type == "private" ? "Dynamic" : null
    subnet_id                     = var.lb_type == "private" ? "/subscriptions/67d6c4c6-913c-4f47-b3e1-eab7b50d229d/resourceGroups/Nothing/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-2/subnets/snet-denmarkeast-1" : null
    public_ip_address_id          = var.lb_type == "public" ? azurerm_public_ip.main[0].id : null
  }

}

resource "azurerm_lb_backend_address_pool" "main" {
  count           = var.lb_type != null ? 1 : 0
  loadbalancer_id = azurerm_lb.main[0].id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_backend_address_pool_address" "main" {
  count                   = var.lb_type != null ? var.vm_count : 0
  name                    = "${var.component_name}-${var.env}-${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main[0].id
  ip_address              = azurerm_network_interface.main[count.index].private_ip_address
  virtual_network_id      = "/subscriptions/67d6c4c6-913c-4f47-b3e1-eab7b50d229d/resourceGroups/Nothing/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-2/subnets/snet-denmarkeast-1"
  # "/subscriptions/67d6c4c6-913c-4f47-b3e1-eab7b50d229d/resourceGroups/Nothing/providers/Microsoft.Network/virtualNetworks/vnet-denmarkeast-2"

}

resource "azurerm_lb_rule" "main" {
  count                          = var.lb_type != null ? 1 : 0
  loadbalancer_id                = azurerm_lb.main[0].id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.port
  backend_port                   = var.port
  frontend_ip_configuration_name = "${var.component_name}-${var.env}"
}
