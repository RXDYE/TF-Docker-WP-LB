resource "azurerm_resource_group" "main" {
  name     = "${var.resource-group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.resource-group}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.main.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"

}
resource "azurerm_public_ip" "main" {
  name                = "${var.resource-group}-public-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  allocation_method   = "Static"
}
###
resource "azurerm_network_security_group" "main" {
  name                = "${var.resource-group}-security-group"
  location            = "${var.location}"
  resource_group_name = "${var.resource-group}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}



###
resource "azurerm_network_interface" "main" {
  name                      = "${var.resource-group}-nic"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.resource-group}-vm"
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_B1s"


  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "docker-server"
    admin_username = "rxdye"
  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/rxdye/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }
  provisioner "file" {
    source      = "scripts/docker-deployment.sh"
    destination = "/tmp/docker-deployment.sh"
    connection {
      host        = "${azurerm_public_ip.main.ip_address}"
      user        = "rxdye"
      type        = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      port        = 22
      agent       = false
      timeout     = "1m"
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = "${azurerm_public_ip.main.ip_address}"
      user        = "rxdye"
      type        = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"
      port        = 22
      agent       = false
      timeout     = "1m"
    }
    inline = [
      "sudo chmod 777 /tmp/docker-deployment.sh",
      "sudo /tmp/docker-deployment.sh ${var.container_registry_host} ${var.container_registry_password} ${var.container_registry_username}",
    ]
  }
}
