resource "azurerm_resource_group" "rg" {
  name     = "rg-matteo-app"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-matteo-app"
  address_space        = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-matteo-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-matteo-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "matteo-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Taille de la VM, à ajuster selon tes besoins
  admin_username      = "azureuser"
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:/Users/GUY/.ssh/my_azure_key.pub")
  }

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    environment = "production"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "pip3 install flask",
      "cd /home/azureuser/flask_app",
      "echo '[Unit]' | sudo tee /etc/systemd/system/flaskapp.service",
      "echo 'Description=Flask App' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo '[Service]' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'ExecStart=/usr/bin/python3 /home/azureuser/flask_app/app.py' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo '[Install]' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/flaskapp.service",
      "sudo systemctl enable flaskapp",
      "sudo systemctl start flaskapp"
    ]

    connection {
      type        = "ssh"
      host        = azurerm_public_ip.public_ip.ip_address
      user        = "azureuser"
      private_key = file("C:/Users/GUY/.ssh/my_azure_key")
    }
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-matteo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_storage_account" "storage" {
  name                     = "matteoappstorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "static-files"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"  # Sécuriser l'accès aux fichiers
}

resource "azurerm_postgresql_server" "postgresql_db" {
  name                         = "matteodbserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  sku_name                     = "B_Gen5_1"
  version                      = "11"
  administrator_login          = "matteoadmin"
  administrator_login_password = "Matteo@dmin"
  storage_mb                   = 5120
  backup_retention_days        = 7
  ssl_enforcement_enabled      = true

  tags = {
    environment = "production"
  }
}
