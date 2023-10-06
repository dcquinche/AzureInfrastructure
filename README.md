# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
 1. [Content](#content)
 2. [The Policy](#the-policy)
 3. [Packer Image](#packer-image)
 4. [Terraform Resources](#terraform-resources)

#### Content
In the project folder, you can find:
 - the policy.json file: which contains the policy rule to deny deployments that don't have tags.
 - the server.json file: which contains the builders, variables and provisioners to create the packer image.
 - the main.tf file: which contains all the resources needed to deploy the project.
 - the vars.tf file: which contains the variables that the user should enter them after running some terraform commands, like the username, password, resources prefix, location, number of virtual machines and the id of the image that packer generates. With the exception of the password, all variables have a default value in case it is not entered.
  - the solution.plan file: which contains the result of the terraform plan command.

In the Assets folder, you can find two folders (CLI and Portal) with screenshots of the process executed and the results obtained.

#### The Policy
  You can create the policy with the following commands, bearing in mind that it is located in the policy.json file.

  ```
  az policy definition create --name tagging-policy --mode Indexed --rules policy.json
  ```

  ```
  az policy assignment create --name tagging-policy --policy tagging-policy
  ```

#### Packer Image
  First, you should export the environment variables. For this project, make sure you export the ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_SUBSCRIPTION_ID variables. In a Linux System you could do it like this.

  ```
  export ARM_CLIENT_ID=<client-application-id>
  ```

  ```
  export ARM_CLIENT_SECRET=<client-secret-key>
  ```

  ```
  export ARM_SUBSCRIPTION_ID=<client-subscription-id>
  ```

  Second, you can run the following command to create the packer image, bearing in mind that it is located in the server.json file.

  ```
  packer build server.json
  ```

#### Terraform Resources

First, you should init the terraform environment and that will add a foleder and some files in your project.

  ```
  terraform init
  ```

Before you plan and deploy you project, you could verify for an existing group resource if you want to deploy with that one. With the following command, you can get the client subscription id and use it on the next step.

  ```
  az group show --name <resource-group-name> --query id --output tsv
  ```

In this case, I deployed the project on an existing resource group, so I imported it using the client subscription id.

  ```
  terraform import azurerm_resource_group.<resource-group-name> /subscriptions/<client-subscription-id>/resourceGroups/<resource-group-name>
  ```

Now, you can plan and deploy the project using the following commands and entering the requested variables.

  ```
  terraform plan -out solution.plan
  ```

  ```
  terraform apply "solution.plan"
  ```

At the end, you could use the next command to destroy all the resources previously created.

  ```
  terraform destroy
  ```

The process shown above was run in the powershell terminal with the exception of the packer part which was run in the bash terminal.

### Output

#### The Policy
  Running the following command, you can see the tagging-policy created above.

  ```
  az policy assignment list
  ```

  ![Tagging Policy](https://github.com/dcquinche/AzureInfrastructure/blob/main/Assets/CLI/PolicyList.png)

#### Packer Image
  Running the following command, you can see the packer image created above.

  ```
  az image list
  ```

  ![Packer Image](https://github.com/dcquinche/AzureInfrastructure/blob/main/Assets/CLI/ImageList.png)

#### Terraform Resources
  Running the following command, you can see the resources created above (I put it on a code block here because of its length).

  ```
  terraform show
  ```

  ```
  # azurerm_availability_set.main:
  resource "azurerm_availability_set" "main" {
      id                           = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Compute/availabilitySets/talan-as"
      location                     = "eastus"
      managed                      = true
      name                         = "talan-as"
      platform_fault_domain_count  = 3
      platform_update_domain_count = 5
      resource_group_name          = "Azuredevops"
      tags                         = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
  }

  # azurerm_lb.main:
  resource "azurerm_lb" "main" {
      id                   = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/talan-lb"
      location             = "eastus"
      name                 = "talan-lb"
      private_ip_addresses = []
      resource_group_name  = "Azuredevops"
      sku                  = "Basic"
      sku_tier             = "Regional"
      tags                 = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }

      frontend_ip_configuration {
          id                            = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/talan-lb/frontendIPConfigurations/PublicIPAddress"
          inbound_nat_rules             = []
          load_balancer_rules           = []
          name                          = "PublicIPAddress"
          outbound_rules                = []
          private_ip_address_allocation = "Dynamic"
          public_ip_address_id          = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/talan-ip"
          zones                         = []
      }
  }

  # azurerm_lb_backend_address_pool.main:
  resource "azurerm_lb_backend_address_pool" "main" {
      backend_ip_configurations = []
      id                        = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/talan-lb/backendAddressPools/BackEndAddressPool"
      inbound_nat_rules         = []
      load_balancing_rules      = []
      loadbalancer_id           = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/loadBalancers/talan-lb"
      name                      = "BackEndAddressPool"
      outbound_rules            = []
  }

  # azurerm_linux_virtual_machine.main[0]:
  resource "azurerm_linux_virtual_machine" "main" {
      admin_password                                         = (sensitive value)
      admin_username                                         = "azureuser"
      allow_extension_operations                             = true
      bypass_platform_safety_checks_on_user_schedule_enabled = false
      computer_name                                          = "talan-vm-0"
      disable_password_authentication                        = false
      encryption_at_host_enabled                             = false
      extensions_time_budget                                 = "PT1H30M"
      id                                                     = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/talan-vm-0"
      location                                               = "eastus"
      max_bid_price                                          = -1
      name                                                   = "talan-vm-0"
      network_interface_ids                                  = [
          "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/talan-nic-0",
      ]
      patch_assessment_mode                                  = "ImageDefault"
      patch_mode                                             = "ImageDefault"
      platform_fault_domain                                  = -1
      priority                                               = "Regular"
      private_ip_address                                     = "10.0.2.5"
      private_ip_addresses                                   = [
          "10.0.2.5",
      ]
      provision_vm_agent                                     = true
      public_ip_addresses                                    = []
      resource_group_name                                    = "Azuredevops"
      secure_boot_enabled                                    = false
      size                                                   = "Standard_D2s_v3"
      source_image_id                                        = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/myPackerImageProject"
      tags                                                   = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
      virtual_machine_id                                     = "9d707acd-b9b6-4756-8665-2e21b37b249a"
      vtpm_enabled                                           = false

      os_disk {
          caching                   = "ReadWrite"
          disk_size_gb              = 30
          name                      = "talan-vm-0_disk1_1948e9e53f924b2a9536a01701920f59"
          storage_account_type      = "Standard_LRS"
          write_accelerator_enabled = false
      }
  }

  # azurerm_linux_virtual_machine.main[1]:
  resource "azurerm_linux_virtual_machine" "main" {
      admin_password                                         = (sensitive value)
      admin_username                                         = "azureuser"
      allow_extension_operations                             = true
      bypass_platform_safety_checks_on_user_schedule_enabled = false
      computer_name                                          = "talan-vm-1"
      disable_password_authentication                        = false
      encryption_at_host_enabled                             = false
      extensions_time_budget                                 = "PT1H30M"
      id                                                     = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Compute/virtualMachines/talan-vm-1"
      location                                               = "eastus"
      max_bid_price                                          = -1
      name                                                   = "talan-vm-1"
      network_interface_ids                                  = [
          "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/talan-nic-1",
      ]
      patch_assessment_mode                                  = "ImageDefault"
      patch_mode                                             = "ImageDefault"
      platform_fault_domain                                  = -1
      priority                                               = "Regular"
      private_ip_address                                     = "10.0.2.4"
      private_ip_addresses                                   = [
          "10.0.2.4",
      ]
      provision_vm_agent                                     = true
      public_ip_addresses                                    = []
      resource_group_name                                    = "Azuredevops"
      secure_boot_enabled                                    = false
      size                                                   = "Standard_D2s_v3"
      source_image_id                                        = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/myPackerImageProject"
      tags                                                   = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
      virtual_machine_id                                     = "2006c695-5d43-4b9b-91e0-2bb83a332991"
      vtpm_enabled                                           = false

      os_disk {
          caching                   = "ReadWrite"
          disk_size_gb              = 30
          name                      = "talan-vm-1_disk1_2bf53d8c0dc347f8861a37b5abe244ff"
          storage_account_type      = "Standard_LRS"
          write_accelerator_enabled = false
      }
  }

  # azurerm_managed_disk.main:
  resource "azurerm_managed_disk" "main" {
      create_option                     = "Empty"
      disk_iops_read_only               = 0
      disk_iops_read_write              = 500
      disk_mbps_read_only               = 0
      disk_mbps_read_write              = 60
      disk_size_gb                      = 1
      id                                = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Compute/disks/talan-md"
      location                          = "eastus"
      max_shares                        = 0
      name                              = "talan-md"
      on_demand_bursting_enabled        = false
      optimized_frequent_attach_enabled = false
      performance_plus_enabled          = false
      public_network_access_enabled     = true
      resource_group_name               = "Azuredevops"
      storage_account_type              = "Standard_LRS"
      tags                              = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
      trusted_launch_enabled            = false
      upload_size_bytes                 = 0
  }

  # azurerm_network_interface.main[0]:
  resource "azurerm_network_interface" "main" {
      applied_dns_servers           = []
      dns_servers                   = []
      enable_accelerated_networking = false
      enable_ip_forwarding          = false
      id                            = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/talan-nic-0"
      internal_domain_name_suffix   = "tckuhicbh1de5fuumih2sf0w3f.bx.internal.cloudapp.net"
      location                      = "eastus"
      name                          = "talan-nic-0"
      private_ip_address            = "10.0.2.5"
      private_ip_addresses          = [
          "10.0.2.5",
      ]
      resource_group_name           = "Azuredevops"
      tags                          = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }

      ip_configuration {
          name                          = "internal"
          primary                       = true
          private_ip_address            = "10.0.2.5"
          private_ip_address_allocation = "Dynamic"
          private_ip_address_version    = "IPv4"
          subnet_id                     = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/talan-network/subnets/internal"
      }
  }

  # azurerm_network_interface.main[1]:
  resource "azurerm_network_interface" "main" {
      applied_dns_servers           = []
      dns_servers                   = []
      enable_accelerated_networking = false
      enable_ip_forwarding          = false
      id                            = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/networkInterfaces/talan-nic-1"
      internal_domain_name_suffix   = "tckuhicbh1de5fuumih2sf0w3f.bx.internal.cloudapp.net"
      location                      = "eastus"
      name                          = "talan-nic-1"
      private_ip_address            = "10.0.2.4"
      private_ip_addresses          = [
          "10.0.2.4",
      ]
      resource_group_name           = "Azuredevops"
      tags                          = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }

      ip_configuration {
          name                          = "internal"
          primary                       = true
          private_ip_address            = "10.0.2.4"
          private_ip_address_allocation = "Dynamic"
          private_ip_address_version    = "IPv4"
          subnet_id                     = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/talan-network/subnets/internal"
      }
  }

  # azurerm_network_security_group.main:
  resource "azurerm_network_security_group" "main" {
      id                  = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/networkSecurityGroups/talan-nsg"
      location            = "eastus"
      name                = "talan-nsg"
      resource_group_name = "Azuredevops"
      security_rule       = [
          {
              access                                     = "Allow"
              description                                = ""
              destination_address_prefix                 = "VirtualNetwork"
              destination_address_prefixes               = []
              destination_application_security_group_ids = []
              destination_port_range                     = "*"
              destination_port_ranges                    = []
              direction                                  = "Inbound"
              name                                       = "AllowInboundSameSubnetVms"
              priority                                   = 110
              protocol                                   = "*"
              source_address_prefix                      = "VirtualNetwork"
              source_address_prefixes                    = []
              source_application_security_group_ids      = []
              source_port_range                          = "*"
              source_port_ranges                         = []
          },
          {
              access                                     = "Allow"
              description                                = ""
              destination_address_prefix                 = "VirtualNetwork"
              destination_address_prefixes               = []
              destination_application_security_group_ids = []
              destination_port_range                     = "*"
              destination_port_ranges                    = []
              direction                                  = "Outbound"
              name                                       = "AllowOutboundSameSubnetVms"
              priority                                   = 100
              protocol                                   = "*"
              source_address_prefix                      = "VirtualNetwork"
              source_address_prefixes                    = []
              source_application_security_group_ids      = []
              source_port_range                          = "*"
              source_port_ranges                         = []
          },
          {
              access                                     = "Deny"
              description                                = ""
              destination_address_prefix                 = "*"
              destination_address_prefixes               = []
              destination_application_security_group_ids = []
              destination_port_range                     = "*"
              destination_port_ranges                    = []
              direction                                  = "Inbound"
              name                                       = "DenyInboundInternet"
              priority                                   = 120
              protocol                                   = "*"
              source_address_prefix                      = "Internet"
              source_address_prefixes                    = []
              source_application_security_group_ids      = []
              source_port_range                          = "*"
              source_port_ranges                         = []
          },
      ]
      tags                = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
  }

  # azurerm_public_ip.main:
  resource "azurerm_public_ip" "main" {
      allocation_method       = "Static"
      ddos_protection_mode    = "VirtualNetworkInherited"
      id                      = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/publicIPAddresses/talan-ip"
      idle_timeout_in_minutes = 4
      ip_address              = "172.172.231.7"
      ip_tags                 = {}
      ip_version              = "IPv4"
      location                = "eastus"
      name                    = "talan-ip"
      resource_group_name     = "Azuredevops"
      sku                     = "Basic"
      sku_tier                = "Regional"
      tags                    = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
      zones                   = []
  }

  # azurerm_resource_group.Azuredevops:
  resource "azurerm_resource_group" "Azuredevops" {
      id       = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops"
      location = "eastus"
      name     = "Azuredevops"
      tags     = {}
  }

  # azurerm_subnet.internal:
  resource "azurerm_subnet" "internal" {
      address_prefixes                               = [
          "10.0.2.0/24",
      ]
      enforce_private_link_endpoint_network_policies = false
      enforce_private_link_service_network_policies  = false
      id                                             = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/talan-network/subnets/internal"
      name                                           = "internal"
      private_endpoint_network_policies_enabled      = true
      private_link_service_network_policies_enabled  = true
      resource_group_name                            = "Azuredevops"
      service_endpoint_policy_ids                    = []
      service_endpoints                              = []
      virtual_network_name                           = "talan-network"
  }

  # azurerm_virtual_network.main:
  resource "azurerm_virtual_network" "main" {
      address_space           = [
          "10.0.0.0/22",
      ]
      dns_servers             = []
      flow_timeout_in_minutes = 0
      guid                    = "a0439598-3e41-4fc6-9694-620fc91756ed"
      id                      = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/talan-network"
      location                = "eastus"
      name                    = "talan-network"
      resource_group_name     = "Azuredevops"
      subnet                  = [
          {
              address_prefix = "10.0.2.0/24"
              id             = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/Azuredevops/providers/Microsoft.Network/virtualNetworks/talan-network/subnets/internal"
              name           = "internal"
              security_group = ""
          },
      ]
      tags                    = {
          "project_name" = "Azure-Udacity-Project"
          "source"       = "terraform"
      }
  }
  ```




