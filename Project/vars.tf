variable "username" {
  description = "The admin username."
  default = "azureuser"
}

variable "password" {
  description = "The admin password."
}

variable "prefix" {
  description = "The prefix that is going to be used for all resources."
  default = "talan-udacity"
}

variable "location" {
  description = "The azure region in which all resources are going to be created."
  default = "eastus"
}

variable "vms_number" {
  description = "The number of virtual machines that are going to be deployed."
  type = number
  default = "2"
}

variable "packer_image" {
  description = "The image's id created by packer to deploy the virtual machines."
  default = "/subscriptions/7de72e36-dc87-4e3f-aa67-6dacbc9993c6/resourceGroups/AZUREDEVOPS/providers/Microsoft.Compute/images/myPackerImageProject"
}
